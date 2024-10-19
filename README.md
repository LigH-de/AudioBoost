# AudioBoost plugin for AviSynth
### (c) 2024, Mario \*LigH\* Rohkrämer, contributions from Asd-g and qyot27

## Purpose

This audio filter works like a dynamic compressor on a per-sample basis (immediate response; no attack, no release).
A soft saturation will avoid clipping, but it will distort the waveform.
The result may sound different; it may have side effects on audio which relies on phase angles (like Dolby ProLogic matrix surround).
Some curves are equivalent to the booster features already used in BeSweet (DSPguru), HeadAC3he (DarkAvenger), and AudioLimiter (dimzon).

## Parameters

**boost**<br>
`float [0.5 {4.0} 20.0]`<br>
amplification factor the input samples are multiplied with before the clipping curve is applied

**limit**<br>
`float [0.1 {0.95} 1.0]`<br>
limiting factor the amplified and clipped samples are multiplied with before the result is returned

**curve**<br>
`int [0 {1} 4]`<br>
* **0:** linear amplification, hard clipping
* **1:** hyperbolic tangent curve, soft clipping
* **2:** square ratio sigmoid curve, softer clipping
* **3:** scaled arcus tangent curve, very soft clipping
* **4:** absolute ratio sigmoid curve, softest clipping

**norm**<br>
`bool {true}`<br>
If enabled (by default it is), the curve gets scaled so that an input audio sample with maximum value will return with maximum value (before the limiting); this will cause a slightly higher amplification for the softer curves in lower volumes.

<hr>

*Note: C++ interface version requires the same compiler family as the one avisynth.dll was built with; C interface version is more cross-compiler compatible.*
