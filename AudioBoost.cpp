// AudioBoost: Soft clipping amplifier plugin for AviSynth v2.6+ (c) 2024-2026, Mario *LigH* Rohkrämer
// equivalent to algorithms provided by me to be used in BeSweet (c) DSPguru and HeadAC3he (c) DarkAvenger

#ifdef AVS_WINDOWS
#include <windows.h>
#else
#include <avs/posix.h>
#endif
#include <cmath>
#include <algorithm>
#include <avisynth.h>

#ifndef M_PI
#define M_PI 3.1415926535897932384626433832795028842
#endif

#define HalfPi M_PI/2.0f

class AudioBoost : public GenericVideoFilter {
public:
	AudioBoost(PClip _child, float _fBoost, float _fLimit, int _iSoftness, bool _bNormalize);
	void __stdcall GetAudio(void* buf, int64_t start, int64_t count, IScriptEnvironment* env);
private:
	float fBoost, fLimit;
	int iSoftness;
	bool bNormalize;
	SFLOAT TanH(SFLOAT val);
	SFLOAT ScaledArcTan(SFLOAT val);
	SFLOAT LinearRatioSigmoid(SFLOAT val);
	SFLOAT SquareRatioSigmoid(SFLOAT val);
	SFLOAT DoubleSquareRatioSigmoid(SFLOAT val);
	SFLOAT TripleSquareRatioSigmoid(SFLOAT val);
};

AudioBoost::AudioBoost(PClip _child, float _fBoost, float _fLimit, int _iSoftness, bool _bNormalize) : GenericVideoFilter(_child) {
	fBoost = _fBoost;
	fLimit = _fLimit;
	iSoftness = _iSoftness;
	bNormalize = _bNormalize;
}

void __stdcall AudioBoost::GetAudio(void* buf, int64_t start, int64_t count, IScriptEnvironment* env) {
	child->GetAudio(buf, start, count, env);
	int channels = vi.AudioChannels();
	SFLOAT val, maxval;

	switch (iSoftness) {
	case 1:
		maxval = TripleSquareRatioSigmoid(fBoost);
		break;
	case 2:
		maxval = DoubleSquareRatioSigmoid(fBoost);
		break;
	case 3:
		maxval = TanH(fBoost);
		break;
	case 4:
		maxval = SquareRatioSigmoid(fBoost);
		break;
	case 5:
		maxval = ScaledArcTan(fBoost);
		break;
	case 6:
		maxval = LinearRatioSigmoid(fBoost);
		break;
	default:
		maxval = 1.0f;
	}
	if (vi.SampleType() == SAMPLE_FLOAT) {
		SFLOAT* samples = (SFLOAT*)buf;
		for (int i = 0; i < count; i++) {
			for (int j = 0; j < channels; j++) {
				switch (iSoftness) {
				case 0:
					val = fabs(samples[i * channels + j] * fBoost);
					if (val > 1.0f) val = 1.0f;
					if (samples[i * channels + j] < 0.0f) val = -val;
					break;
				case 1:
					val = TripleSquareRatioSigmoid(samples[i * channels + j] * fBoost) * fLimit;
					break;
				case 2:
					val = DoubleSquareRatioSigmoid(samples[i * channels + j] * fBoost) * fLimit;
					break;
				case 3:
					val = TanH(samples[i * channels + j] * fBoost) * fLimit;
					break;
				case 4:
					val = SquareRatioSigmoid(samples[i * channels + j] * fBoost) * fLimit;
					break;
				case 5:
					val = ScaledArcTan(samples[i * channels + j] * fBoost) * fLimit;
					break;
				case 6:
					val = LinearRatioSigmoid(samples[i * channels + j] * fBoost) * fLimit;
					break;
				default:
					val = samples[i * channels + j];
				}
				if (bNormalize) val /= maxval;
				samples[i * channels + j] = val * fLimit;
			}
		}
	}
}

SFLOAT AudioBoost::TanH(SFLOAT val) {
	return tanh(val);
	// return 1.0f-2.0f/(1.0f+exp(2.0f*val));
}

SFLOAT AudioBoost::ScaledArcTan(SFLOAT val) {
	return atan(val * HalfPi) / HalfPi;
}

SFLOAT AudioBoost::LinearRatioSigmoid(SFLOAT val) {
	return val / (1.0f + fabs(val));
}

SFLOAT AudioBoost::SquareRatioSigmoid(SFLOAT val) {
	return val / sqrt(1.0f + val * val);
}

SFLOAT AudioBoost::DoubleSquareRatioSigmoid(SFLOAT val) {
	return val / sqrt(sqrt(1.0f + val * val * val * val));
}

SFLOAT AudioBoost::TripleSquareRatioSigmoid(SFLOAT val) {
	SFLOAT tval = val;
	tval *= tval; // val^2
	tval *= tval; // val^4
	tval *= tval; // val^8
	return val / sqrt(sqrt(sqrt(1.0f + tval)));
}

AVSValue __cdecl Create_AudioBoost(AVSValue args, void*, IScriptEnvironment* env) {
	PClip clip = args[0].AsClip();

	if (!clip->GetVideoInfo().HasAudio())
		env->ThrowError("Input clip does not have audio.");

	if (!(clip->GetVideoInfo().SampleType() & SAMPLE_FLOAT))
		env->ThrowError("Input audio sample format must be float.");

	float fBoost = args[1].AsFloat(4.0f);
	if ((fBoost < 0.5f) || (fBoost > 20.0f))
		env->ThrowError("Boost factor is outside a sensible range [0.5 .. 20.0] (default is 4.0).");

	float fLimit = args[2].AsFloat(0.95f);
	if ((fLimit < 0.1f) || (fLimit > 1.0f))
		env->ThrowError("Limit factor is outside a sensible range [0.1 .. 1.0] (use e.g. Amplify or Normalize as post processing instead).");

	int iSoftness = args[3].AsInt(1);
	if ((iSoftness < 0) || (iSoftness > 6))
		env->ThrowError("Softness index must be in a range 0 .. 6 (default is 1).");

	return new AudioBoost(clip, fBoost, fLimit, iSoftness, args[4].AsBool(true));
}

const AVS_Linkage* AVS_linkage = 0;

extern "C" __declspec(dllexport) const char* __stdcall AvisynthPluginInit3(IScriptEnvironment* env, const AVS_Linkage* const vectors) {
	AVS_linkage = vectors;
	env->AddFunction("AudioBoost", "c[boost]f[limit]f[softness]i[norm]b", Create_AudioBoost, 0);
	return "AudioBoost soft clipping amplifier";
}
