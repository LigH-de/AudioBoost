declare name "AudioBoost";
declare version "0.3.3";
declare author "LigH & Gemini";

import("stdfaust.lib");

// --- UI Controls with smoothing (si.smoo) to ensure continuous input signals ---
paramGroup(x) = vgroup("Parameters",x);
sliderGroup(x) = hgroup("Factors",x);
softness  = paramGroup(sliderGroup(vslider("Softness", 0, 0, 6, 1)));
boost     = paramGroup(sliderGroup(vslider("Boost [scale:log]", 1.0, 1.0, 10.0, 0.01) : si.smoo));
limit     = paramGroup(sliderGroup(vslider("Limit", 0.95, 0.5, 1.0, 0.01) : si.smoo));
normalize = paramGroup(checkbox("Normalize [init:1]") : si.smoo);

// --- saturation curves ---
sat_hard(x) = ba.if(x > 1.0, 1.0, ba.if(x < -1.0, -1.0, x));
sat_tanh(x) = ma.tanh(x);
sat_atan(x) = (2.0 / ma.PI) * atan(x * ma.PI / 2.0);
sat_soft(x) = x / (1.0 + abs(x));
sat_sqr1(x) = x / sqrt(1.0 + (x * x));
sat_sqr2(x) = x / sqrt(sqrt(1.0 + (x * x * x * x)));
sat_sqr3(x) = x / sqrt(sqrt(sqrt(1.0 + (x * x * x * x * x * x * x * x))));

// --- resilient method choice depending on "Softness" input at runtime ---
saturation(method, x) = 
    ba.if(method < 0.5, sat_hard(x),
    ba.if(method < 1.5, sat_sqr3(x),
    ba.if(method < 2.5, sat_sqr3(x),
    ba.if(method < 3.5, sat_tanh(x),
    ba.if(method < 4.5, sat_sqr1(x),
    ba.if(method < 5.5, sat_atan(x), 
    sat_soft(x)))))));

// --- DSP core method with some crash protection for picky VST hosts ---
dsp_core(x) = raw_sat * scale * limit
with {
    boosted = x * boost;
    raw_sat = saturation(softness, boosted);
    
    // protection against division by zero via max(ma.EPSILON)
    max_sat = max(ma.EPSILON, saturation(softness, 1.0 * boost));
    
    // soft threshold for the "Normalize" switch 
    scale   = (1.0 - normalize) + (normalize * (1.0 / max_sat));
};

// --- Level bars protected against small infinity by max(ma.EPSILON) ---
amp_meter(x) = x : an.amp_follower_ud(0.01, 1.0) : max(ma.EPSILON) : ba.linear2db;

in_mon(x)  = attach(x, amp_meter(x) : hgroup("Levels", vbargraph("Input [unit:dB]", -60, 10)));
out_mon(x) = attach(x, amp_meter(x) : hgroup("Levels", vbargraph("Output [unit:dB]", -60, 10)));

// --- stereo output ---
process = (in_mon, in_mon) : (dsp_core, dsp_core) : (out_mon, out_mon);
