# AudioBoost plugin for AviSynth
### (c) 2024, Mario \*LigH\* Rohkrämer

## Purpose

This audio filter works like a dynamic compressor on a per-sample basis (immediate response; no attack, no release).
A soft saturation will avoid clipping, but it will distort the waveform.
The result may sound different; it may have side effects on audio which relies on phase angles (like Dolby ProLogic matrix surround).
Some curves are equivalent to the booster features already used in BeSweet (DSPguru), HeadAC3he (DarkAvenger), and AudioLimiter (dimzon).

## Parameters

boost
: `float [0.5 {4.0} 20.0]`
: amplification factor the input samples are multiplied with before the clipping curve is applied

limit
: `float [0.1 {0.95} 1.0]`
: limiting factor the amplified and clipped samples are multiplied with before the result is returned

curve
: `int [0 {1} 4]`
: * **0:** linear amplification, hard clipping
: * **1:** hyperbolic tangent curve, soft clipping
: * **2:** square ratio sigmoid curve, softer clipping
: * **3:** scaled arcus tangent curve, very soft clipping
: * **4:** absolute ratio sigmoid curve, softest clipping

norm
: `bool {true}`
: If enabled (by default it is), the curve gets scaled so that an input audio sample with maximum value will return with maximum value (before the limiting); this will cause a slightly higher amplification for the softer curves in lower volumes.

Note: This project may not correctly build in MinGW with GCC, I sadly have to recommend MSVC.
