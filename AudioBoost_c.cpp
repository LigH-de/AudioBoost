// AudioBoost: Soft clipping amplifier plugin for AviSynth v2.5+ (c) 2024-2026, Mario *LigH* Rohkrämer
// equivalent to algorithms provided by me to be used in BeSweet (c) DSPguru and HeadAC3he (c) DarkAvenger

#include <algorithm>
#include <cmath>
#include <avisynth_c.h>

static constexpr float HalfPi{ 3.1415926535897932384626433832795028842f / 2.0f };

struct AudioBoost
{
	float fBoost;
	float fLimit;
	float maxval;
};

template <int iSoftness, bool bNormalize>
static int AVSC_CC avs_get_audio_AudioBoost(AVS_FilterInfo* fi, void* buf, int64_t start, int64_t count)
{
	AudioBoost* d{ reinterpret_cast<AudioBoost*>(fi->user_data) };

	if (avs_get_audio(fi->child, buf, start, count))
		return 0;

	const int channels{ fi->vi.nchannels };
	const float fBoost{ d->fBoost };
	const float fLimit{ d->fLimit };
	const float maxval{ d->maxval };

	float* samples{ reinterpret_cast<float*>(buf) };

	for (int i{ 0 }; i < count; ++i)
	{
		for (int j{ 0 }; j < channels; ++j)
		{
			float val{ [&]()
			{
				const float sampleval{ samples[i * channels + j] };
				const float boostedval{ sampleval * fBoost };
				const float clampedval{ std::min(std::fabsf(boostedval), 1.0f) };
				float tval{ boostedval };
				switch (iSoftness) {
					case 0: // hard limit
						return (sampleval < 0.0f) ? -clampedval : clampedval;
						break;
					case 1: // triple square ratio sigmoid
						tval *= tval; // boostedval^2
						tval *= tval; // boostedval^4
						tval *= tval; // boostedval^8
						return boostedval / std::sqrtf(std::sqrtf(std::sqrtf(1.0f + tval))) * fLimit;
						break;
					case 2: // double square ratio sigmoid
						tval *= tval; // boostedval^2
						tval *= tval; // boostedval^4
						return boostedval / std::sqrtf(std::sqrtf(1.0f + tval)) * fLimit;
						break;
					case 3: // hyperbolic tangens
						return std::tanhf(boostedval) * fLimit;
						break;
					case 4: // square ratio sigmoid
						return boostedval / std::sqrtf(1.0f + boostedval * boostedval) * fLimit;
						break;
					case 5: // scaled arcus tangens
						return std::atanf(boostedval * HalfPi) / HalfPi * fLimit;
						break;
					case 6: // absolute ratio sigmoid
						return boostedval / (1.0f + std::fabsf(boostedval)) * fLimit;
						break;
					default: // passthrough fallback
						return sampleval;
				}
			}() };

			if (bNormalize)
				val /= maxval;

			samples[i * channels + j] = val * fLimit;
		}
	}

	return 0;
}

static void AVSC_CC free_AudioBoost(AVS_FilterInfo* fi)
{
	AudioBoost* d{ static_cast<AudioBoost*>(fi->user_data) };

	delete d;
}

static int AVSC_CC set_cache_hints_AudioBoost(AVS_FilterInfo* fi, int cachehints, int frame_range)
{
	return cachehints == AVS_CACHE_GET_MTMODE ? 1 : 0;
}

static AVS_Value AVSC_CC Create_AudioBoost(AVS_ScriptEnvironment* env, AVS_Value args, void* param)
{
	enum
	{
		Clip,
		Boost,
		Limit,
		Softness,
		Norm
	};

	AudioBoost* d{ new AudioBoost() };

	AVS_FilterInfo* fi;
	AVS_Clip* clip{ avs_new_c_filter(env, &fi, avs_array_elt(args, Clip), 1) };

	const auto set_error{ [&](const char* msg)
	{
		avs_release_clip(clip);

		return avs_new_value_error(msg);
	} };

	// Make sure AviSynth.lib version used for building is >= r3928 (the minimum version required to run the plugin).
	if (avs_check_version(env, 10))
		return set_error("AudioBoost: AviSynth+ version must be r3928 or later.");
	if (!avs_has_audio(&fi->vi))
		return set_error("AudioBoost: input clip does not have audio.");
	if (avs_sample_type(&fi->vi) != AVS_SAMPLE_FLOAT)
		return set_error("AudioBoost: input audio sample format must be float.");

	const float fBoost{ avs_defined(avs_array_elt(args, Boost)) ?
		static_cast<float>(avs_as_float(avs_array_elt(args, Boost))) : 4.0f };
	if ((fBoost < 0.5f) || (fBoost > 20.0f))
		return set_error("AudioBoost: boost factor is outside a sensible range [0.5 .. 20.0] (default is 4.0).");

	const float fLimit{ avs_defined(avs_array_elt(args, Limit)) ?
		static_cast<float>(avs_as_float(avs_array_elt(args, Limit))) : 0.95f };
	if ((fLimit < 0.1f) || (fLimit > 1.0f))
		return set_error("AudioBoost: limit factor is outside a sensible range [0.1 .. 1.0] (use e.g. Amplify or Normalize as post processing instead).");

	d->fBoost = fBoost;
	d->fLimit = fLimit;

	const int iSoftness{ avs_defined(avs_array_elt(args, Softness)) ? avs_as_int(avs_array_elt(args, Softness)) : 1 };
	if ((iSoftness < 0) || (iSoftness > 6))
		return set_error("AudioBoost: softness index must be in a range 0 .. 6 (default is 1).");

	const bool bNormalize = avs_defined(avs_array_elt(args, Norm)) ? !!avs_as_bool(avs_array_elt(args, Norm)) : true;

	switch (iSoftness)
	{
		case 1: d->maxval = fBoost / sqrtf(sqrtf(sqrtf(1.0f + powf(fBoost, 8.0f)))); break;
		case 2: d->maxval = fBoost / sqrtf(sqrtf(1.0f + fBoost * fBoost * fBoost * fBoost)); break;
		case 3: d->maxval = std::tanh(fBoost); break;
		case 4: d->maxval = fBoost / sqrtf(1.0f + fBoost * fBoost); break;
		case 5: d->maxval = std::atan(fBoost * HalfPi) / HalfPi; break;
		case 6: d->maxval = 1.0f / (1.0f + fabs(fBoost)); break;
		default: d->maxval = 1.0f;
	}

	AVS_Value v{ avs_new_value_clip(clip) };

	fi->user_data = reinterpret_cast<void*>(d);
	fi->set_cache_hints = set_cache_hints_AudioBoost;
	fi->free_filter = free_AudioBoost;

	switch (iSoftness)
	{
		case 1: fi->get_audio = (bNormalize) ? avs_get_audio_AudioBoost<1, true> : avs_get_audio_AudioBoost<1, false>; break;
		case 2: fi->get_audio = (bNormalize) ? avs_get_audio_AudioBoost<2, true> : avs_get_audio_AudioBoost<2, false>; break;
		case 3: fi->get_audio = (bNormalize) ? avs_get_audio_AudioBoost<3, true> : avs_get_audio_AudioBoost<3, false>; break;
		case 4: fi->get_audio = (bNormalize) ? avs_get_audio_AudioBoost<4, true> : avs_get_audio_AudioBoost<4, false>; break;
		case 5: fi->get_audio = (bNormalize) ? avs_get_audio_AudioBoost<5, true> : avs_get_audio_AudioBoost<5, false>; break;
		case 6: fi->get_audio = (bNormalize) ? avs_get_audio_AudioBoost<6, true> : avs_get_audio_AudioBoost<6, false>; break;
		default: fi->get_audio = (bNormalize) ? avs_get_audio_AudioBoost<0, true> : avs_get_audio_AudioBoost<0, false>;
	}

	avs_release_clip(clip);

	return v;
}

const char* AVSC_CC avisynth_c_plugin_init(AVS_ScriptEnvironment* env)
{
	avs_add_function(env, "AudioBoost", "c[boost]f[limit]f[softness]i[norm]b", Create_AudioBoost, 0);

	return "AudioBoost soft clipping amplifier";
}
