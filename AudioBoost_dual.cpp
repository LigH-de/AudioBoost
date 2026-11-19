// AudioBoost: Soft clipping amplifier plugin for AviSynth v2.5+ & VapourSynth v4 (c) 2024-2026, Mario *LigH* Rohkrämer
// equivalent to algorithms provided by me to be used in BeSweet (c) DSPguru and HeadAC3he (c) DarkAvenger
// some bug fixes by Myrsloik with the help of AI's by Google and Microsoft

#include <algorithm>
#include <cmath>
#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
// The AviSynth C API is looked up at runtime in the AviSynth that loads the plugin instead of being
// imported, so the DLL doesn't depend on AviSynth.dll and VapourSynth can load it where AviSynth
// isn't installed. This makes the header declare the API as function pointer types, and leaves out
// its own loader, which insists on every function of the newest API being present.
#define AVSC_NO_DECLSPEC
#define EXTERNAL_AVS_C_API_LOADER
#endif
#include <avisynth_c.h>
#include "VapourSynth4.h"

// Constant for scaled arcus tangens logic
static constexpr float HalfPi{ 3.1415926535897932384626433832795028842f / 2.0f };

// Holds configuration parameter calculations
struct AudioBoost
{
	float fBoost;
	float fLimit;
	float maxval;
};

// Detached internal DSP processing logic operating on a single sample
template <int iSoftness, bool bNormalize>
static inline float process_single_sample(float sampleval, float fBoost, float fLimit, float maxval)
{
	const float boostedval{ sampleval * fBoost };
	const float clampedval{ std::min(std::fabsf(boostedval), 1.0f) };
	float tval{ boostedval };
	float val{ boostedval };

	switch (iSoftness) {
	case 0: // Hard limit
		val = (sampleval < 0.0f) ? -clampedval : clampedval;
		break;
	case 1: // Triple square ratio sigmoid
		tval *= tval; // boostedval^2
		tval *= tval; // boostedval^4
		tval *= tval; // boostedval^8
		val = boostedval / std::sqrtf(std::sqrtf(std::sqrtf(1.0f + tval)));
		break;
	case 2: // Double square ratio sigmoid
		tval *= tval; // boostedval^2
		tval *= tval; // boostedval^4
		val = boostedval / std::sqrtf(std::sqrtf(1.0f + tval));
		break;
	case 3: // Hyperbolic tangens
		val = std::tanhf(boostedval);
		break;
	case 4: // Square ratio sigmoid
		val = boostedval / std::sqrtf(1.0f + boostedval * boostedval);
		break;
	case 5: // Scaled arcus tangens
		val = std::atanf(boostedval * HalfPi) / HalfPi;
		break;
	case 6: // Absolute ratio sigmoid
		val = boostedval / (1.0f + std::fabsf(boostedval));
		break;
	default: // Passthrough fallback
		return sampleval;
	}

	if (bNormalize)
		val /= maxval;

	return val * fLimit;
}

// ============================================================================
// AVISYNTH C-API IMPLEMENTATION
// ============================================================================

// The AviSynth C API functions the plugin calls, filled in by load_avs_api() when AviSynth loads it
#ifdef _WIN32
#define AVS_API_ENTRY(name) avs_##name##_func name
#else
#define AVS_API_ENTRY(name) decltype(&::avs_##name) name
#endif

static struct
{
	AVS_API_ENTRY(add_function);
	AVS_API_ENTRY(check_version);
	AVS_API_ENTRY(get_audio);
	AVS_API_ENTRY(get_video_info);
	AVS_API_ENTRY(invoke);
	AVS_API_ENTRY(new_c_filter);
	AVS_API_ENTRY(release_clip);
	AVS_API_ENTRY(release_value);
	AVS_API_ENTRY(set_to_clip);
	AVS_API_ENTRY(take_clip);
} avs;

static bool load_avs_api()
{
#ifdef _WIN32
	// AviSynth is already loaded when it calls the plugin's entry point
	const HMODULE lib{ GetModuleHandleW(L"AviSynth.dll") };
	if (!lib)
		return false;
#define AVS_LOAD(name) (avs.name = reinterpret_cast<avs_##name##_func>(GetProcAddress(lib, "avs_" #name)))
#else
#define AVS_LOAD(name) (avs.name = &::avs_##name)
#endif
	return AVS_LOAD(add_function) && AVS_LOAD(check_version) && AVS_LOAD(get_audio) && AVS_LOAD(get_video_info) &&
		AVS_LOAD(invoke) && AVS_LOAD(new_c_filter) && AVS_LOAD(release_clip) && AVS_LOAD(release_value) &&
		AVS_LOAD(set_to_clip) && AVS_LOAD(take_clip);
#undef AVS_LOAD
}

template <int iSoftness, bool bNormalize>
static int AVSC_CC avs_get_audio_AudioBoost(AVS_FilterInfo* fi, void* buf, int64_t start, int64_t count)
{
	AudioBoost* d{ reinterpret_cast<AudioBoost*>(fi->user_data) };

	if (avs.get_audio(fi->child, buf, start, count))
		return 0;

	const int channels{ fi->vi.nchannels };
	const float fBoost{ d->fBoost };
	const float fLimit{ d->fLimit };
	const float maxval{ d->maxval };

	float* samples{ reinterpret_cast<float*>(buf) };

	// AviSynth serves interleaved audio data (Ch0, Ch1, Ch0, Ch1...)
	for (int i{ 0 }; i < count; ++i)
	{
		for (int j{ 0 }; j < channels; ++j)
		{
			samples[i * channels + j] = process_single_sample<iSoftness, bNormalize>(samples[i * channels + j], fBoost, fLimit, maxval);
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
	enum { Clip, Boost, Limit, Softness, Norm };

	AVS_Value clipVal = avs_array_elt(args, Clip);

	// FIXED: Use avs_take_clip to extract the AVS_Clip pointer from the AVS_Value variant union
	AVS_Clip* checkClip = avs.take_clip(clipVal, env);
	const AVS_VideoInfo* vi_check = avs.get_video_info(checkClip);

	// Check if the input contains an active audio track
	if (!vi_check || !avs_has_audio(vi_check))
	{
		avs.release_clip(checkClip);
		return avs_new_value_error("AudioBoost: input clip does not have audio.");
	}

	// If sample format is not Float, call internal "ConvertAudio" via env->Invoke
	bool converted{ false };
	if (avs_sample_type(vi_check) != AVS_SAMPLE_FLOAT)
	{
		// Clean up the initial tracking clip reference before replacing it via Invoke
		avs.release_clip(checkClip);

		AVS_Value ca_args[3];
		ca_args[0] = clipVal;
		ca_args[1] = avs_new_value_int(AVS_SAMPLE_FLOAT); // Preferred format
		ca_args[2] = avs_new_value_int(AVS_SAMPLE_FLOAT); // Restricted format target

		AVS_Value invokeRes = avs.invoke(env, "ConvertAudio", avs_new_value_array(ca_args, 3), nullptr);
		if (avs_is_error(invokeRes))
			return invokeRes;

		clipVal = invokeRes;
		converted = true;

		// Re-track the newly converted clip structure
		checkClip = avs.take_clip(clipVal, env);
	}

	AudioBoost* d{ new AudioBoost() };
	AVS_FilterInfo* fi;

	// Create the filter using our validated clipVal structure
	AVS_Clip* clip{ avs.new_c_filter(env, &fi, clipVal, 1) };

	// Ensure the temporary reference used for info queries is released safely
	avs.release_clip(checkClip);
	// avs_invoke's result must be released; the filter holds its own reference to the converted clip
	if (converted)
		avs.release_value(clipVal);

	const auto set_error{ [&](const char* msg) {
		avs.release_clip(clip);
		delete d;
		return avs_new_value_error(msg);
	} };

	if (avs.check_version(env, 10))
		return set_error("AudioBoost: AviSynth+ version must be r3928 or later.");

	const float fBoost{ avs_defined(avs_array_elt(args, Boost)) ? static_cast<float>(avs_as_float(avs_array_elt(args, Boost))) : 4.0f };
	if ((fBoost < 0.5f) || (fBoost > 20.0f))
		return set_error("AudioBoost: boost factor is outside a sensible range [0.5 .. 20.0] (default is 4.0).");

	const float fLimit{ avs_defined(avs_array_elt(args, Limit)) ? static_cast<float>(avs_as_float(avs_array_elt(args, Limit))) : 0.95f };
	if ((fLimit < 0.1f) || (fLimit > 1.0f))
		return set_error("AudioBoost: limit factor is outside a sensible range [0.1 .. 1.0].");

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
		case 3: d->maxval = std::tanhf(fBoost); break;
		case 4: d->maxval = fBoost / sqrtf(1.0f + fBoost * fBoost); break;
		case 5: d->maxval = std::atanf(fBoost * HalfPi) / HalfPi; break;
		case 6: d->maxval = fBoost / (1.0f + std::fabsf(fBoost)); break;
		default: d->maxval = 1.0f;
	}

	AVS_Value v;
	avs.set_to_clip(&v, clip);
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

	avs.release_clip(clip);
	return v;
}

const char* AVSC_CC avisynth_c_plugin_init(AVS_ScriptEnvironment* env)
{
	if (!load_avs_api())
		return "AudioBoost: the AviSynth C API functions it needs are missing";

	avs.add_function(env, "AudioBoost", "c[boost]f[limit]f[softness]i[norm]b", Create_AudioBoost, 0);

	return "AudioBoost soft clipping amplifier";
}

// ============================================================================
// VAPOURSYNTH4 C-API IMPLEMENTATION (Strictly API v4 compliant for R65 / R81+)
// ============================================================================

struct VSAudioBoostData
{
	VSNode* node;
	VSAudioInfo info;
	AudioBoost config;
	int iSoftness;
	bool bNormalize;
};

// In API v4, the frame callback strictly returns 'const VSFrame*' for both video and audio
template <int iSoftness, bool bNormalize>
static const VSFrame* VS_CC vs_get_audio_AudioBoost(int n, int activationReason, void* instanceData, void** frameData, VSFrameContext* frameCtx, VSCore* core, const VSAPI* vsapi)
{
	VSAudioBoostData* d{ reinterpret_cast<VSAudioBoostData*>(instanceData) };

	if (activationReason == arInitial)
	{
		vsapi->requestFrameFilter(n, d->node, frameCtx);
	}
	else if (activationReason == arAllFramesReady)
	{
		// API v4 uses generic getFrameFilter for audio frames
		const VSFrame* srcFrame{ vsapi->getFrameFilter(n, d->node, frameCtx) };

		// API v4 uses getFrameLength to retrieve the number of samples in an audio frame
		const int64_t sampleCount{ vsapi->getFrameLength(srcFrame) };

		// Create a new generic VSFrame instance for audio output
		VSFrame* dstFrame{ vsapi->newAudioFrame(&d->info.format, static_cast<int>(sampleCount), srcFrame, core) };

		const float fBoost{ d->config.fBoost };
		const float fLimit{ d->config.fLimit };
		const float maxval{ d->config.maxval };
		const int channels{ d->info.format.numChannels };

		// VapourSynth4 manages planar audio (isolated buffer per audio channel/plane)
		for (int j = 0; j < channels; ++j)
		{
			// API v4 maps generic getReadPtr and getWritePtr to plane/channel index
			const float* srcSamples{ reinterpret_cast<const float*>(vsapi->getReadPtr(srcFrame, j)) };
			float* dstSamples{ reinterpret_cast<float*>(vsapi->getWritePtr(dstFrame, j)) };

			for (int64_t i = 0; i < sampleCount; ++i)
			{
				dstSamples[i] = process_single_sample<iSoftness, bNormalize>(srcSamples[i], fBoost, fLimit, maxval);
			}
		}

		vsapi->freeFrame(srcFrame);
		return dstFrame;
	}

	return nullptr;
}

static void VS_CC vs_free_AudioBoost(void* instanceData, VSCore* core, const VSAPI* vsapi)
{
	VSAudioBoostData* d{ static_cast<VSAudioBoostData*>(instanceData) };
	vsapi->freeNode(d->node);
	delete d;
}

static void VS_CC vs_Create_AudioBoost(const VSMap* in, VSMap* out, void* userData, VSCore* core, const VSAPI* vsapi)
{
	VSAudioBoostData* d{ new VSAudioBoostData() };
	int err{ 0 };

	VSNode* inputNode = vsapi->mapGetNode(in, "clip", 0, &err);
	const VSAudioInfo* initialInfo = vsapi->getAudioInfo(inputNode);

	const auto set_vs_error{ [&](const char* msg) {
		vsapi->mapSetError(out, msg);
		if (inputNode) vsapi->freeNode(inputNode);
		delete d;
	} };

	if (!initialInfo || initialInfo->format.numChannels == 0)
		return set_vs_error("AudioBoost: input clip does not have audio.");

	// Fixed: Checking 'sampleType' against 'stFloat' matching VSSampleType definitions
	if (initialInfo->format.sampleType != stFloat)
	{
		VSMap* invIn = vsapi->createMap();

		vsapi->mapSetNode(invIn, "clip", inputNode, maReplace);
		// Fixed: Map parameter set to "sampletype" utilizing the native 'stFloat' enum token
		vsapi->mapSetInt(invIn, "sampletype", stFloat, maReplace);
		vsapi->mapSetInt(invIn, "bits", 32, maReplace); // Float audio implies 32-bit single precision

		// Invoke standard plugin function to convert input track format
		VSMap* invOut = vsapi->invoke(vsapi->getPluginByID("com.vapoursynth.std", core), "AudioResample", invIn);

		if (vsapi->mapGetError(invOut))
		{
			vsapi->mapSetError(out, vsapi->mapGetError(invOut));
			vsapi->freeMap(invIn);
			vsapi->freeMap(invOut);
			vsapi->freeNode(inputNode);
			delete d;
			return;
		}

		// Transfer node tracking lifecycle to converted Float audio stream
		vsapi->freeNode(inputNode);
		inputNode = vsapi->mapGetNode(invOut, "clip", 0, &err);

		vsapi->freeMap(invIn);
		vsapi->freeMap(invOut);
	}

	d->node = inputNode;
	d->info = *vsapi->getAudioInfo(d->node);

	d->config.fBoost = static_cast<float>(vsapi->mapGetFloat(in, "boost", 0, &err));
	if (err) d->config.fBoost = 4.0f;
	if ((d->config.fBoost < 0.5f) || (d->config.fBoost > 20.0f))
		return set_vs_error("AudioBoost: boost factor is outside a sensible range [0.5 .. 20.0] (default is 4.0).");

	d->config.fLimit = static_cast<float>(vsapi->mapGetFloat(in, "limit", 0, &err));
	if (err) d->config.fLimit = 0.95f;
	if ((d->config.fLimit < 0.1f) || (d->config.fLimit > 1.0f))
		return set_vs_error("AudioBoost: limit factor is outside a sensible range [0.1 .. 1.0].");

	d->iSoftness = static_cast<int>(vsapi->mapGetInt(in, "softness", 0, &err));
	if (err) d->iSoftness = 1;
	if ((d->iSoftness < 0) || (d->iSoftness > 6))
		return set_vs_error("AudioBoost: softness index must be in a range 0 .. 6 (default is 1).");

	d->bNormalize = vsapi->mapGetInt(in, "norm", 0, &err) != 0;
	if (err) d->bNormalize = true;

	switch (d->iSoftness)
	{
		case 1: d->config.maxval = d->config.fBoost / sqrtf(sqrtf(sqrtf(1.0f + powf(d->config.fBoost, 8.0f)))); break;
		case 2: d->config.maxval = d->config.fBoost / sqrtf(sqrtf(1.0f + d->config.fBoost * d->config.fBoost * d->config.fBoost * d->config.fBoost)); break;
		case 3: d->config.maxval = std::tanhf(d->config.fBoost); break;
		case 4: d->config.maxval = d->config.fBoost / sqrtf(1.0f + d->config.fBoost * d->config.fBoost); break;
		case 5: d->config.maxval = std::atanf(d->config.fBoost * HalfPi) / HalfPi; break;
		case 6: d->config.maxval = d->config.fBoost / (1.0f + std::fabsf(d->config.fBoost)); break;
		default: d->config.maxval = 1.0f;
	}

	// Fixed: Utilizing the strict VapourSynth API v4 type 'VSFilterGetFrame'
	VSFilterGetFrame getFrameFunc{ nullptr };

	// Map compile-time template branches for optimized execution paths
	if (d->bNormalize) {
		switch (d->iSoftness) {
			case 1: getFrameFunc = vs_get_audio_AudioBoost<1, true>; break;
			case 2: getFrameFunc = vs_get_audio_AudioBoost<2, true>; break;
			case 3: getFrameFunc = vs_get_audio_AudioBoost<3, true>; break;
			case 4: getFrameFunc = vs_get_audio_AudioBoost<4, true>; break;
			case 5: getFrameFunc = vs_get_audio_AudioBoost<5, true>; break;
			case 6: getFrameFunc = vs_get_audio_AudioBoost<6, true>; break;
			default: getFrameFunc = vs_get_audio_AudioBoost<0, true>; break;
		}
	}
	else {
		switch (d->iSoftness) {
			case 1: getFrameFunc = vs_get_audio_AudioBoost<1, false>; break;
			case 2: getFrameFunc = vs_get_audio_AudioBoost<2, false>; break;
			case 3: getFrameFunc = vs_get_audio_AudioBoost<3, false>; break;
			case 4: getFrameFunc = vs_get_audio_AudioBoost<4, false>; break;
			case 5: getFrameFunc = vs_get_audio_AudioBoost<5, false>; break;
			case 6: getFrameFunc = vs_get_audio_AudioBoost<6, false>; break;
			default: getFrameFunc = vs_get_audio_AudioBoost<0, false>; break;
		}
	}

	VSFilterDependency deps[] = { {d->node, rpStrictSpatial} };
	vsapi->createAudioFilter(out, "AudioBoost", &d->info, getFrameFunc, vs_free_AudioBoost, fmParallel, deps, 1, d, core);
}

// ============================================================================
// VAPOURSYNTH4 PLUGIN INITIALIZATION (Correct VapourSynth R81 / API v4 Code)
// ============================================================================

// Fixed: The second argument MUST be 'const VSPLUGINAPI* vspapi' (not VSAPI*)
VS_EXTERNAL_API(void) VapourSynthPluginInit2(VSPlugin* plugin, const VSPLUGINAPI* vspapi)
{
	// Fixed: Now calling via the dedicated plugin API interface pointer
	vspapi->configPlugin(
		"com.ligh.audioboost",           // Unique plugin identifier
		"ab",                            // Default namespace
		"AudioBoost soft clipping amplifier",  // Plugin description
		VS_MAKE_VERSION(0, 4),           // Plugin version
		VAPOURSYNTH_API_VERSION,         // Supported API version
		0,                               // Flags (0 for default)
		plugin
	);

	// Fixed: Function registration through the plugin interface
	vspapi->registerFunction(
		"AudioBoost",
		"clip:anode;"
		"boost:float:opt;"
		"limit:float:opt;"
		"softness:int:opt;"
		"norm:int:opt;",
		"clip:anode;",
		vs_Create_AudioBoost,
		nullptr,
		plugin
	);
}
