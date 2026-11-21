library AudioBoost_p;

{$mode objfpc}{$H+}

uses
  Math,
  ctypes,
  avisynth_c;

const
  HalfPi: Single = 3.1415926535897932384626433832795028842 / 2.0;

type
  PAudioBoost = ^TAudioBoost;
  TAudioBoost = record
    fBoost: Single;
    fLimit: Single;
    maxval: Single;
  end;

function AvsStr(const s: PAnsiChar): PChar; inline;
begin
  Result := PChar(Pointer(s));
end;

function avs_as_bool_def(v: AVS_Value; default_v: boolean): boolean; inline;
begin
  if avs_defined(v) <> 0
  then Result := avs_as_bool(v) <> 0
  else Result := default_v;
end;

function avs_as_int_def(v: AVS_Value; default_v: cint): cint; inline;
begin
  if avs_defined(v) <> 0
  then Result := avs_as_int(v)
  else Result := default_v;
end;

function avs_as_float_def(v: AVS_Value; default_v: cdouble): cdouble; inline;
begin
  if avs_defined(v) <> 0
  then Result := avs_as_float(v)
  else Result := default_v;
end;

// -----------------------------------------------------------------------------
// Generic core logic (embedded via 'inline' into specific variants)
// -----------------------------------------------------------------------------
function ProcessAudioGeneric(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64; const iSoftness: Integer; const bNormalize: Boolean): Integer; inline;
var
  d: PAudioBoost;
  channels: Integer;
  fBoost, fLimit, maxval: Single;
  samples: PSingle;
  i, j, idx: Integer;
  sampleval, boostedval, clampedval, tval, val: Single;
begin
  d := PAudioBoost(fi^.user_data);

  if avs_get_audio(fi^.child, buf, start, count) <> 0 then Exit(0);

  channels := fi^.vi.nchannels;
  fBoost := d^.fBoost;
  fLimit := d^.fLimit;
  maxval := d^.maxval;
  samples := PSingle(buf);

  for i := 0 to count - 1 do
  begin
    for j := 0 to channels - 1 do
    begin
      idx := i * channels + j;
      sampleval := samples[idx];
      boostedval := sampleval * fBoost;
      tval := boostedval;

      case iSoftness of
        0: // hard limit
          begin
            clampedval := Min(Abs(boostedval), 1.0);
            if sampleval < 0.0 then
              val := -clampedval
            else
              val := clampedval;
          end;
        1: // triple square ratio sigmoid
          begin
            tval := tval * tval; // ^2
            tval := tval * tval; // ^4
            tval := tval * tval; // ^8
            val := boostedval / Sqrt(Sqrt(Sqrt(1.0 + tval)));
          end;
        2: // double square ratio sigmoid
          begin
            tval := tval * tval; // ^2
            tval := tval * tval; // ^4
            val := boostedval / Sqrt(Sqrt(1.0 + tval));
          end;
        3: // hyperbolic tangens
          begin
            val := Tanh(boostedval);
          end;
        4: // square ratio sigmoid
          begin
            val := boostedval / Sqrt(1.0 + boostedval * boostedval);
          end;
        5: // scaled arcus tangens
          begin
            val := ArcTan(boostedval * HalfPi) / HalfPi;
          end;
        6: // absolute ratio sigmoid
          begin
            val := boostedval / (1.0 + Abs(boostedval));
          end;
      else
        val := sampleval;
      end;

      if bNormalize
      then val := val / maxval;

      samples[idx] := val * fLimit;
    end;
  end;

  Result := 0;
end;

// -----------------------------------------------------------------------------
// Specialized instances (stdcall matching TGetAudioFunc in avisynth_c.pas)
// -----------------------------------------------------------------------------
function avs_get_audio_0_F(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 0, False); end;

function avs_get_audio_0_T(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 0, True); end;

function avs_get_audio_1_F(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 1, False); end;

function avs_get_audio_1_T(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 1, True); end;

function avs_get_audio_2_F(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 2, False); end;

function avs_get_audio_2_T(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 2, True); end;

function avs_get_audio_3_F(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 3, False); end;

function avs_get_audio_3_T(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 3, True); end;

function avs_get_audio_4_F(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 4, False); end;

function avs_get_audio_4_T(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 4, True); end;

function avs_get_audio_5_F(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 5, False); end;

function avs_get_audio_5_T(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 5, True); end;

function avs_get_audio_6_F(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 6, False); end;

function avs_get_audio_6_T(fi: PAVS_FilterInfo; buf: Pointer; start, count: Int64): Integer; stdcall;
begin Result := ProcessAudioGeneric(fi, buf, start, count, 6, True); end;

const
  GetAudioDispatch: array[0..6, Boolean] of TGetAudioFunc = (
    (@avs_get_audio_0_F, @avs_get_audio_0_T),
    (@avs_get_audio_1_F, @avs_get_audio_1_T),
    (@avs_get_audio_2_F, @avs_get_audio_2_T),
    (@avs_get_audio_3_F, @avs_get_audio_3_T),
    (@avs_get_audio_4_F, @avs_get_audio_4_T),
    (@avs_get_audio_5_F, @avs_get_audio_5_T),
    (@avs_get_audio_6_F, @avs_get_audio_6_T)
  );

// -----------------------------------------------------------------------------
// Filter callbacks & initialization
// -----------------------------------------------------------------------------
procedure free_AudioBoost(fi: PAVS_FilterInfo); stdcall;
var
  d: PAudioBoost;
begin
  d := PAudioBoost(fi^.user_data);
  Dispose(d);
end;

function set_cache_hints_AudioBoost(fi: PAVS_FilterInfo; cachehints: Integer; frame_range: Integer): Integer; stdcall;
begin
  if cachehints = AVS_CACHE_GET_MTMODE
  then Result := 1
  else Result := 0;
end;

procedure Create_AudioBoost(env: PAVS_ScriptEnvironment; ret: PAVS_Value; msvc_args: AVS_Value; param: Pointer); stdcall;

const
  ArgClip = 0;
  ArgBoost = 1;
  ArgLimit = 2;
  ArgSoftness = 3;
  ArgNorm = 4;
var
  args: AVS_Value;
  d: PAudioBoost;
  fi: PAVS_FilterInfo;
  clip: PAVS_Clip;
  fBoost, fLimit: Single;
  iSoftness: Integer;
  bNormalize: Boolean;
  v: AVS_Value;

  function SetError(const msg: PAnsiChar): Boolean;
  begin
    avs_release_clip(clip);
    Dispose(d);
    ret^ := avs_new_value_error(msg);
    Result := True;
  end;

begin
  args := AVS_Value(msvc_args);
  New(d);
  clip := avs_new_c_filter(env, @fi, avs_array_elt(args, ArgClip), ciTrue);

  // avs_check_version returns 0 when the version is sufficient, else -1
  if avs_check_version(env, 10) <> 0
  then begin
    SetError('AudioBoost: AviSynth+ version must be r3928 or later.');
    Exit;
  end;

  if avs_has_audio(@fi^.vi) = ciFalse
  then begin
    SetError('AudioBoost: input clip does not have audio.');
    Exit;
  end;

  if fi^.vi.sample_type <> AVS_SAMPLE_FLOAT
  then begin
    SetError('AudioBoost: input audio sample format must be float.');
    Exit;
  end;

  fBoost := avs_as_float_def(avs_array_elt(args, ArgBoost), 4.0);
  if (fBoost < 0.5) or (fBoost > 20.0)
  then begin
    SetError('AudioBoost: boost factor is outside a sensible range [0.5 .. 20.0] (default is 4.0).');
    Exit;
  end;

  fLimit := avs_as_float_def(avs_array_elt(args, ArgLimit), 0.95);
  if (fLimit < 0.1) or (fLimit > 1.0)
  then begin
    SetError('AudioBoost: limit factor is outside a sensible range [0.1 .. 1.0] (use e.g. Amplify or Normalize as post processing instead).');
    Exit;
  end;

  d^.fBoost := fBoost;
  d^.fLimit := fLimit;

  iSoftness := avs_as_int_def(avs_array_elt(args, ArgSoftness), 1);
  if (iSoftness < 0) or (iSoftness > 6) 
  then begin
    SetError('AudioBoost: softness index must be in a range 0 .. 6 (default is 1).');
    Exit;
  end;

  bNormalize := avs_as_bool_def(avs_array_elt(args, ArgNorm), True);

  case iSoftness of
    1: d^.maxval := fBoost / Sqrt(Sqrt(Sqrt(1.0 + Power(fBoost, 8.0))));
    2: d^.maxval := fBoost / Sqrt(Sqrt(1.0 + fBoost * fBoost * fBoost * fBoost));
    3: d^.maxval := Tanh(fBoost);
    4: d^.maxval := fBoost / Sqrt(1.0 + fBoost * fBoost);
    5: d^.maxval := ArcTan(fBoost * HalfPi) / HalfPi;
    6: d^.maxval := fBoost / (1.0 + Abs(fBoost));
  else
    d^.maxval := 1.0;
  end;

  v := avs_new_value_clip(clip);

  fi^.user_data := d;
  fi^.set_cache_hints := @set_cache_hints_AudioBoost;
  fi^.free_filter := @free_AudioBoost;
  fi^.get_audio := GetAudioDispatch[iSoftness, bNormalize];

  avs_release_clip(clip);

  ret^ := v;
end;

function avisynth_c_plugin_init(env: PAVS_ScriptEnvironment): PAnsiChar; stdcall;
begin
  avs_add_function_r(
    env,
    'AudioBoost',
    'c[boost]f[limit]f[softness]i[norm]b',
    @Create_AudioBoost,
    nil
  );
  Result := 'AudioBoost soft clipping amplifier';
end;

exports
  avisynth_c_plugin_init
{$IFDEF CPU32}
  name '_avisynth_c_plugin_init@4'
{$ENDIF};

end.
