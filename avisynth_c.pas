unit avisynth_c;

// Avisynth C interface unit for Pascal version 14.1
// Created by Fredrik Mellbin (Myrsloik)
// converted to FreePascal with AI support, additional manual fixes

{$mode objfpc}{$H+}
{$PACKRECORDS C}
{$MACRO ON}

interface

uses
  ctypes;

const
  ciFalse = 0;
  ciTrue = 1;
{$IFDEF WINDOWS}
  AVISYNTH_LIB = 'avisynth.dll';
{$ELSE}
  {$IFDEF DARWIN}
  AVISYNTH_LIB = 'libavisynth.dylib';
  {$ELSE}
  AVISYNTH_LIB = 'libavisynth.so';
  {$ENDIF}
{$ENDIF}

  AVS_FRAME_ALIGN = 64; // FRAME_ALIGN in avs/config.h, the same on all platforms

// Interface versions
  AVISYNTH_INTERFACE_CLASSIC_VERSION = 6;
  AVISYNTH_INTERFACE_VERSION = 14;
  AVISYNTHPLUS_INTERFACE_BUGFIX_VERSION = 1;

// Audio sample types
  AVS_SAMPLE_INT8 = 1 shl 0;
  AVS_SAMPLE_INT16 = 1 shl 1;
  AVS_SAMPLE_INT24 = 1 shl 2;
  AVS_SAMPLE_INT32 = 1 shl 3;
  AVS_SAMPLE_FLOAT = 1 shl 4;

// Planar formats
  AVS_DEFAULT_PLANE = 0;
  AVS_PLANAR_Y = 1 shl 0;
  AVS_PLANAR_U = 1 shl 1;
  AVS_PLANAR_V = 1 shl 2;
  AVS_PLANAR_ALIGNED = 1 shl 3;
  AVS_PLANAR_Y_ALIGNED = AVS_PLANAR_Y or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_U_ALIGNED = AVS_PLANAR_U or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_V_ALIGNED = AVS_PLANAR_V or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_A = 1 shl 4;
  AVS_PLANAR_R = 1 shl 5;
  AVS_PLANAR_G = 1 shl 6;
  AVS_PLANAR_B = 1 shl 7;
  AVS_PLANAR_A_ALIGNED = AVS_PLANAR_A or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_R_ALIGNED = AVS_PLANAR_R or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_G_ALIGNED = AVS_PLANAR_G or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_B_ALIGNED = AVS_PLANAR_B or AVS_PLANAR_ALIGNED;

// Color space attributes
  AVS_CS_YUVA = 1 shl 27;
  AVS_CS_BGR = 1 shl 28;
  AVS_CS_YUV = 1 shl 29;
  AVS_CS_INTERLEAVED = 1 shl 30;
  AVS_CS_PLANAR = integer(1 shl 31);

  AVS_CS_SHIFT_SUB_WIDTH = 0;
  AVS_CS_SHIFT_SUB_HEIGHT = 8;
  AVS_CS_SHIFT_SAMPLE_BITS = 16;

  AVS_CS_SUB_WIDTH_MASK = 7 shl AVS_CS_SHIFT_SUB_WIDTH;
  AVS_CS_SUB_WIDTH_1 = 3 shl AVS_CS_SHIFT_SUB_WIDTH;
  AVS_CS_SUB_WIDTH_2 = 0 shl AVS_CS_SHIFT_SUB_WIDTH;
  AVS_CS_SUB_WIDTH_4 = 1 shl AVS_CS_SHIFT_SUB_WIDTH;

  AVS_CS_VPLANEFIRST = 1 shl 3;
  AVS_CS_UPLANEFIRST = 1 shl 4;

  AVS_CS_SUB_HEIGHT_MASK = 7 shl AVS_CS_SHIFT_SUB_HEIGHT;
  AVS_CS_SUB_HEIGHT_1 = 3 shl AVS_CS_SHIFT_SUB_HEIGHT;
  AVS_CS_SUB_HEIGHT_2 = 0 shl AVS_CS_SHIFT_SUB_HEIGHT;
  AVS_CS_SUB_HEIGHT_4 = 1 shl AVS_CS_SHIFT_SUB_HEIGHT;

  AVS_CS_SAMPLE_BITS_MASK = 7 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_8 = 0 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_10 = 5 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_12 = 6 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_14 = 7 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_16 = 1 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_32 = 2 shl AVS_CS_SHIFT_SAMPLE_BITS;

  AVS_CS_PLANAR_MASK = AVS_CS_PLANAR or AVS_CS_INTERLEAVED or AVS_CS_YUV or AVS_CS_BGR or AVS_CS_YUVA or AVS_CS_SAMPLE_BITS_MASK or AVS_CS_SUB_WIDTH_MASK or AVS_CS_SUB_HEIGHT_MASK;
  AVS_CS_PLANAR_FILTER = not (AVS_CS_VPLANEFIRST or AVS_CS_UPLANEFIRST);

  AVS_CS_RGB_TYPE = 1 shl 0;
  AVS_CS_RGBA_TYPE = 1 shl 1;

  AVS_CS_GENERIC_YUV444 = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_1 or AVS_CS_SUB_HEIGHT_1;
  AVS_CS_GENERIC_YUV422 = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_2 or AVS_CS_SUB_HEIGHT_1;
  AVS_CS_GENERIC_YUV420 = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_2 or AVS_CS_SUB_HEIGHT_2;
  AVS_CS_GENERIC_Y = AVS_CS_PLANAR or AVS_CS_INTERLEAVED or AVS_CS_YUV;
  AVS_CS_GENERIC_YA = AVS_CS_PLANAR or AVS_CS_INTERLEAVED or AVS_CS_YUVA;
  AVS_CS_GENERIC_RGBP = AVS_CS_PLANAR or AVS_CS_BGR or AVS_CS_RGB_TYPE;
  AVS_CS_GENERIC_RGBAP = AVS_CS_PLANAR or AVS_CS_BGR or AVS_CS_RGBA_TYPE;
  AVS_CS_GENERIC_YUVA444 = AVS_CS_PLANAR or AVS_CS_YUVA or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_1 or AVS_CS_SUB_HEIGHT_1;
  AVS_CS_GENERIC_YUVA422 = AVS_CS_PLANAR or AVS_CS_YUVA or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_2 or AVS_CS_SUB_HEIGHT_1;
  AVS_CS_GENERIC_YUVA420 = AVS_CS_PLANAR or AVS_CS_YUVA or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_2 or AVS_CS_SUB_HEIGHT_2;
  AVS_CS_GENERIC_YUV440 = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_1 or AVS_CS_SUB_HEIGHT_2;
  AVS_CS_GENERIC_YUVA440 = AVS_CS_PLANAR or AVS_CS_YUVA or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_1 or AVS_CS_SUB_HEIGHT_2;
  AVS_CS_GENERIC_YUV411 = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_4 or AVS_CS_SUB_HEIGHT_1;
  AVS_CS_GENERIC_YUVA411 = AVS_CS_PLANAR or AVS_CS_YUVA or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_4 or AVS_CS_SUB_HEIGHT_1;
  AVS_CS_GENERIC_YUV410 = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_4 or AVS_CS_SUB_HEIGHT_4;
  AVS_CS_GENERIC_YUVA410 = AVS_CS_PLANAR or AVS_CS_YUVA or AVS_CS_VPLANEFIRST or AVS_CS_SUB_WIDTH_4 or AVS_CS_SUB_HEIGHT_4;

// Spezific color formats
  AVS_CS_UNKNOWN = 0;
  AVS_CS_BGR24 = AVS_CS_RGB_TYPE or AVS_CS_BGR or AVS_CS_INTERLEAVED;
  AVS_CS_BGR32 = AVS_CS_RGBA_TYPE or AVS_CS_BGR or AVS_CS_INTERLEAVED;
  AVS_CS_YUY2 = (1 shl 2) or AVS_CS_YUV or AVS_CS_INTERLEAVED;
  AVS_CS_RAW32 = (1 shl 5) or AVS_CS_INTERLEAVED;

  AVS_CS_YV24 = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YV16 = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YV12 = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_I420 = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_SAMPLE_BITS_8 or AVS_CS_UPLANEFIRST or AVS_CS_SUB_WIDTH_2 or AVS_CS_SUB_HEIGHT_2;
  AVS_CS_IYUV = AVS_CS_I420;
  AVS_CS_YV411 = AVS_CS_GENERIC_YUV411 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YUV9 = AVS_CS_GENERIC_YUV410 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_Y8 = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_8;

// 10-16 bit YUV & Y
  AVS_CS_YUV444P10 = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUV422P10 = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUV420P10 = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_Y10 = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_10;

  AVS_CS_YUV444P12 = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUV422P12 = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUV420P12 = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_Y12 = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_12;

  AVS_CS_YUV444P14 = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUV422P14 = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUV420P14 = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_Y14 = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_14;

  AVS_CS_YUV444P16 = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUV422P16 = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUV420P16 = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_Y16 = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_16;

// 32 bit float YUV & Y
  AVS_CS_YUV444PS = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_32;
  AVS_CS_YUV422PS = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_32;
  AVS_CS_YUV420PS = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_32;
  AVS_CS_Y32 = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_32;
  AVS_CS_YS = AVS_CS_Y32;

// RGB packed
  AVS_CS_BGR48 = AVS_CS_RGB_TYPE or AVS_CS_BGR or AVS_CS_INTERLEAVED or
    AVS_CS_SAMPLE_BITS_16;
  AVS_CS_BGR64 = AVS_CS_RGBA_TYPE or AVS_CS_BGR or AVS_CS_INTERLEAVED or
    AVS_CS_SAMPLE_BITS_16;

// RGB planar
  AVS_CS_RGBP = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_RGBP8 = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_RGBP10 = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_RGBP12 = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_RGBP14 = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_RGBP16 = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_RGBPS = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_32;

// RGBA planar
  AVS_CS_RGBAP = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_RGBAP8 = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_RGBAP10 = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_RGBAP12 = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_RGBAP14 = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_RGBAP16 = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_RGBAPS = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_32;

// Planar YUVA
  AVS_CS_YUVA444 = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YUVA422 = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YUVA420 = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YUVA444P10 = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUVA422P10 = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUVA420P10 = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUVA444P12 = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUVA422P12 = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUVA420P12 = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUVA444P14 = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUVA422P14 = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUVA420P14 = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUVA444P16 = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUVA422P16 = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUVA420P16 = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUVA444PS = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_32;
  AVS_CS_YUVA422PS = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_32;
  AVS_CS_YUVA420PS = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_32;

// Planar YUV(A) 4:4:0 (V13)
  AVS_CS_YUV440 = AVS_CS_GENERIC_YUV440 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YUV440P10 = AVS_CS_GENERIC_YUV440 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUV440P12 = AVS_CS_GENERIC_YUV440 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUV440P14 = AVS_CS_GENERIC_YUV440 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUV440P16 = AVS_CS_GENERIC_YUV440 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUV440PS = AVS_CS_GENERIC_YUV440 or AVS_CS_SAMPLE_BITS_32;
  AVS_CS_YUVA440 = AVS_CS_GENERIC_YUVA440 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YUVA440P10 = AVS_CS_GENERIC_YUVA440 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUVA440P12 = AVS_CS_GENERIC_YUVA440 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUVA440P14 = AVS_CS_GENERIC_YUVA440 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUVA440P16 = AVS_CS_GENERIC_YUVA440 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUVA440PS = AVS_CS_GENERIC_YUVA440 or AVS_CS_SAMPLE_BITS_32;

// Planar YUV(A) 4:1:1 (V13)
  AVS_CS_YUV411 = AVS_CS_YV411;
  AVS_CS_YUV411P10 = AVS_CS_GENERIC_YUV411 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUV411P12 = AVS_CS_GENERIC_YUV411 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUV411P14 = AVS_CS_GENERIC_YUV411 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUV411P16 = AVS_CS_GENERIC_YUV411 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUV411PS = AVS_CS_GENERIC_YUV411 or AVS_CS_SAMPLE_BITS_32;
  AVS_CS_YUVA411 = AVS_CS_GENERIC_YUVA411 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YUVA411P10 = AVS_CS_GENERIC_YUVA411 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUVA411P12 = AVS_CS_GENERIC_YUVA411 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUVA411P14 = AVS_CS_GENERIC_YUVA411 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUVA411P16 = AVS_CS_GENERIC_YUVA411 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUVA411PS = AVS_CS_GENERIC_YUVA411 or AVS_CS_SAMPLE_BITS_32;

// Planar YUV(A) 4:1:0 (V13)
  AVS_CS_YUV410 = AVS_CS_YUV9;
  AVS_CS_YUV410P10 = AVS_CS_GENERIC_YUV410 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUV410P12 = AVS_CS_GENERIC_YUV410 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUV410P14 = AVS_CS_GENERIC_YUV410 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUV410P16 = AVS_CS_GENERIC_YUV410 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUV410PS = AVS_CS_GENERIC_YUV410 or AVS_CS_SAMPLE_BITS_32;
  AVS_CS_YUVA410 = AVS_CS_GENERIC_YUVA410 or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YUVA410P10 = AVS_CS_GENERIC_YUVA410 or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YUVA410P12 = AVS_CS_GENERIC_YUVA410 or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YUVA410P14 = AVS_CS_GENERIC_YUVA410 or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YUVA410P16 = AVS_CS_GENERIC_YUVA410 or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YUVA410PS = AVS_CS_GENERIC_YUVA410 or AVS_CS_SAMPLE_BITS_32;

// Y + Alpha 4:0:0 (V13)
  AVS_CS_YA8 = AVS_CS_GENERIC_YA or AVS_CS_SAMPLE_BITS_8;
  AVS_CS_YA10 = AVS_CS_GENERIC_YA or AVS_CS_SAMPLE_BITS_10;
  AVS_CS_YA12 = AVS_CS_GENERIC_YA or AVS_CS_SAMPLE_BITS_12;
  AVS_CS_YA14 = AVS_CS_GENERIC_YA or AVS_CS_SAMPLE_BITS_14;
  AVS_CS_YA16 = AVS_CS_GENERIC_YA or AVS_CS_SAMPLE_BITS_16;
  AVS_CS_YAS = AVS_CS_GENERIC_YA or AVS_CS_SAMPLE_BITS_32;

// AvsChannelMask
  AVS_MASK_SPEAKER_FRONT_LEFT = $1;
  AVS_MASK_SPEAKER_FRONT_RIGHT = $2;
  AVS_MASK_SPEAKER_FRONT_CENTER = $4;
  AVS_MASK_SPEAKER_LOW_FREQUENCY = $8;
  AVS_MASK_SPEAKER_BACK_LEFT = $10;
  AVS_MASK_SPEAKER_BACK_RIGHT = $20;
  AVS_MASK_SPEAKER_FRONT_LEFT_OF_CENTER = $40;
  AVS_MASK_SPEAKER_FRONT_RIGHT_OF_CENTER = $80;
  AVS_MASK_SPEAKER_BACK_CENTER = $100;
  AVS_MASK_SPEAKER_SIDE_LEFT = $200;
  AVS_MASK_SPEAKER_SIDE_RIGHT = $400;
  AVS_MASK_SPEAKER_TOP_CENTER = $800;
  AVS_MASK_SPEAKER_TOP_FRONT_LEFT = $1000;
  AVS_MASK_SPEAKER_TOP_FRONT_CENTER = $2000;
  AVS_MASK_SPEAKER_TOP_FRONT_RIGHT = $4000;
  AVS_MASK_SPEAKER_TOP_BACK_LEFT = $8000;
  AVS_MASK_SPEAKER_TOP_BACK_CENTER = $10000;
  AVS_MASK_SPEAKER_TOP_BACK_RIGHT = $20000;
  AVS_MASK_SPEAKER_DEFINED = $0003FFFF;
  AVS_MASK_SPEAKER_RESERVED = $7FFC0000;
  AVS_MASK_SPEAKER_ALL = cardinal($80000000);

// AvsImageTypeFlags
  AVS_IT_BFF = 1 shl 0;
  AVS_IT_TFF = 1 shl 1;
  AVS_IT_FIELDBASED = 1 shl 2;
  AVS_IT_HAS_CHANNELMASK = 1 shl 3;
  AVS_IT_SPEAKER_FRONT_LEFT = $1 shl 4;
  AVS_IT_SPEAKER_FRONT_RIGHT = $2 shl 4;
  AVS_IT_SPEAKER_FRONT_CENTER = $4 shl 4;
  AVS_IT_SPEAKER_LOW_FREQUENCY = $8 shl 4;
  AVS_IT_SPEAKER_BACK_LEFT = $10 shl 4;
  AVS_IT_SPEAKER_BACK_RIGHT = $20 shl 4;
  AVS_IT_SPEAKER_FRONT_LEFT_OF_CENTER = $40 shl 4;
  AVS_IT_SPEAKER_FRONT_RIGHT_OF_CENTER = $80 shl 4;
  AVS_IT_SPEAKER_BACK_CENTER = $100 shl 4;
  AVS_IT_SPEAKER_SIDE_LEFT = $200 shl 4;
  AVS_IT_SPEAKER_SIDE_RIGHT = $400 shl 4;
  AVS_IT_SPEAKER_TOP_CENTER = $800 shl 4;
  AVS_IT_SPEAKER_TOP_FRONT_LEFT = $1000 shl 4;
  AVS_IT_SPEAKER_TOP_FRONT_CENTER = $2000 shl 4;
  AVS_IT_SPEAKER_TOP_FRONT_RIGHT = $4000 shl 4;
  AVS_IT_SPEAKER_TOP_BACK_LEFT = $8000 shl 4;
  AVS_IT_SPEAKER_TOP_BACK_CENTER = $10000 shl 4;
  AVS_IT_SPEAKER_TOP_BACK_RIGHT = $20000 shl 4;
  AVS_IT_SPEAKER_ALL = $40000 shl 4;
  AVS_IT_SPEAKER_BITS_MASK = (AVS_MASK_SPEAKER_DEFINED shl 4) or AVS_IT_SPEAKER_ALL;
  AVS_IT_NEXT_AVAILABLE = 1 shl 23;

// Filter constants
  AVS_FILTER_TYPE = 1;
  AVS_FILTER_INPUT_COLORSPACE = 2;
  AVS_FILTER_OUTPUT_TYPE = 9;
  AVS_FILTER_NAME = 4;
  AVS_FILTER_AUTHOR = 5;
  AVS_FILTER_VERSION = 6;
  AVS_FILTER_ARGS = 7;
  AVS_FILTER_ARGS_INFO = 8;
  AVS_FILTER_ARGS_DESCRIPTION = 10;
  AVS_FILTER_DESCRIPTION = 11;
  AVS_FILTER_TYPE_AUDIO = 1;
  AVS_FILTER_TYPE_VIDEO = 2;
  AVS_FILTER_OUTPUT_TYPE_SAME = 3;
  AVS_FILTER_OUTPUT_TYPE_DIFFERENT = 4;

// Cache hints
  AVS_CACHE_25_NOTHING_26_UNUSED = 0;
  AVS_CACHE_NOTHING = 10;
  AVS_CACHE_WINDOW = 11;
  AVS_CACHE_GENERIC = 12;
  AVS_CACHE_FORCE_GENERIC = 13;
  AVS_CACHE_GET_POLICY = 30;
  AVS_CACHE_GET_WINDOW = 31;
  AVS_CACHE_GET_RANGE = 32;
  AVS_CACHE_AUDIO = 50;
  AVS_CACHE_AUDIO_NOTHING = 51;
  AVS_CACHE_AUDIO_NONE = 52;
  AVS_CACHE_AUDIO_AUTO_START_OFF = 52;
  AVS_CACHE_AUDIO_AUTO = 53;
  AVS_CACHE_AUDIO_AUTO_START_ON = 53;
  AVS_CACHE_GET_AUDIO_POLICY = 70;
  AVS_CACHE_GET_AUDIO_SIZE = 71;
  AVS_CACHE_PREFETCH_FRAME = 100;
  AVS_CACHE_PREFETCH_GO = 101;
  AVS_CACHE_PREFETCH_AUDIO_BEGIN = 120;
  AVS_CACHE_PREFETCH_AUDIO_STARTLO = 121;
  AVS_CACHE_PREFETCH_AUDIO_STARTHI = 122;
  AVS_CACHE_PREFETCH_AUDIO_COUNT = 123;
  AVS_CACHE_PREFETCH_AUDIO_COMMIT = 124;
  AVS_CACHE_PREFETCH_AUDIO_GO = 125;
  AVS_CACHE_GETCHILD_CACHE_MODE = 200;
  AVS_CACHE_GETCHILD_CACHE_SIZE = 201;
  AVS_CACHE_GETCHILD_AUDIO_MODE = 202;
  AVS_CACHE_GETCHILD_AUDIO_SIZE = 203;
  AVS_CACHE_GETCHILD_COST = 220;
  AVS_CACHE_COST_ZERO = 221;
  AVS_CACHE_COST_UNIT = 222;
  AVS_CACHE_COST_LOW = 223;
  AVS_CACHE_COST_MED = 224;
  AVS_CACHE_COST_HI = 225;
  AVS_CACHE_GETCHILD_THREAD_MODE = 240;
  AVS_CACHE_THREAD_UNSAFE = 241;
  AVS_CACHE_THREAD_CLASS = 242;
  AVS_CACHE_THREAD_SAFE = 243;
  AVS_CACHE_THREAD_OWN = 244;
  AVS_CACHE_GETCHILD_ACCESS_COST = 260;
  AVS_CACHE_ACCESS_RAND = 261;
  AVS_CACHE_ACCESS_SEQ0 = 262;
  AVS_CACHE_ACCESS_SEQ1 = 263;
  AVS_CACHE_AVSPLUS_CONSTANTS = 500;
  AVS_CACHE_DONT_CACHE_ME = 501;
  AVS_CACHE_SET_MIN_CAPACITY = 502;
  AVS_CACHE_SET_MAX_CAPACITY = 503;
  AVS_CACHE_GET_MIN_CAPACITY = 504;
  AVS_CACHE_GET_MAX_CAPACITY = 505;
  AVS_CACHE_GET_SIZE = 506;
  AVS_CACHE_GET_REQUESTED_CAP = 507;
  AVS_CACHE_GET_CAPACITY = 508;
  AVS_CACHE_GET_MTMODE = 509;
  AVS_CACHE_IS_CACHE_REQ = 510;
  AVS_CACHE_IS_CACHE_ANS = 511;
  AVS_CACHE_IS_MTGUARD_REQ = 512;
  AVS_CACHE_IS_MTGUARD_ANS = 513;
  AVS_CACHE_INFORM_NUM_THREADS = 514;
  AVS_CACHE_AVSPLUS_CUDA_CONSTANTS = 600;
  AVS_CACHE_GET_DEV_TYPE = 601;
  AVS_CACHE_GET_CHILD_DEV_TYPE = 602;
  AVS_CACHE_USER_CONSTANTS = 1000;
  AVS_CACHE_USER_FORWARD_BEGIN = $40000000;
  AVS_CACHE_USER_FORWARD_END = $7FFFFFFF;

// Frame property types & errors
  AVS_PROPTYPE_UNSET = Ord('u');
  AVS_PROPTYPE_INT = Ord('i');
  AVS_PROPTYPE_FLOAT = Ord('f');
  AVS_PROPTYPE_DATA = Ord('s');
  AVS_PROPTYPE_CLIP = Ord('c');
  AVS_PROPTYPE_FRAME = Ord('v');

  AVS_GETPROPERROR_SUCCESS = 0;
  AVS_GETPROPERROR_UNSET = 1;
  AVS_GETPROPERROR_TYPE = 2;
  AVS_GETPROPERROR_ERROR = 3;
  AVS_GETPROPERROR_INDEX = 4;

  AVS_PROPAPPENDMODE_REPLACE = 0;
  AVS_PROPAPPENDMODE_APPEND = 1;
  AVS_PROPAPPENDMODE_TOUCH = 2;

  AVS_PROPDATATYPEHINT_UNKNOWN = -1;
  AVS_PROPDATATYPEHINT_BINARY = 0;
  AVS_PROPDATATYPEHINT_UTF8 = 1;

// Environment properties
  AVS_AEP_PHYSICAL_CPUS = 1;
  AVS_AEP_LOGICAL_CPUS = 2;
  AVS_AEP_THREADPOOL_THREADS = 3;
  AVS_AEP_FILTERCHAIN_THREADS = 4;
  AVS_AEP_THREAD_ID = 5;
  AVS_AEP_VERSION = 6;
  AVS_AEP_HOST_SYSTEM_ENDIANNESS = 7;
  AVS_AEP_INTERFACE_VERSION = 8;
  AVS_AEP_INTERFACE_BUGFIX = 9;
  AVS_AEP_CACHESIZE_L2 = 10;
  AVS_AEP_NUM_DEVICES = 901;
  AVS_AEP_FRAME_ALIGN = 902;
  AVS_AEP_PLANE_ALIGN = 903;
  AVS_AEP_SUPPRESS_THREAD = 921;
  AVS_AEP_GETFRAME_RECURSIVE = 922;

// Allocation types
  AVS_ALLOCTYPE_NORMAL_ALLOC = 1;
  AVS_ALLOCTYPE_POOLED_ALLOC = 2;

// Multithreading modes
  AVS_MT_INVALID = 0;
  AVS_MT_NICE_FILTER = 1;
  AVS_MT_MULTI_INSTANCE = 2;
  AVS_MT_SERIALIZED = 3;
  AVS_MT_SPECIAL_MT = 4;
  AVS_MT_MODE_COUNT = 5;

// AVS_Value typen
  AVS_VALUE_TYPE_UNDEFINED = Ord('v');
  AVS_VALUE_TYPE_BOOL = Ord('b');
  AVS_VALUE_TYPE_INT = Ord('i');
  AVS_VALUE_TYPE_LONG = Ord('l');
  AVS_VALUE_TYPE_FLOAT = Ord('f');
  AVS_VALUE_TYPE_DOUBLE = Ord('d');
  AVS_VALUE_TYPE_STRING = Ord('s');
  AVS_VALUE_TYPE_CLIP = Ord('c');
  AVS_VALUE_TYPE_FUNCTION = Ord('n');
  AVS_VALUE_TYPE_ARRAY = Ord('a');
  AVS_VALUE_TYPE_ERROR = Ord('e');

// CPU flags (32-bit)
  AVS_CPU_FORCE = $01;
  AVS_CPU_FPU = $02;
  AVS_CPU_MMX = $04;
  AVS_CPU_INTEGER_SSE = $08;
  AVS_CPU_SSE = $10;
  AVS_CPU_SSE2 = $20;
  AVS_CPU_3DNOW = $40;
  AVS_CPU_3DNOW_EXT = $80;
  AVS_CPU_X86_64 = $A0;
  AVS_CPUF_SSE3 = $100;
  AVS_CPUF_SSSE3 = $200;
  AVS_CPUF_SSE4 = $400;
  AVS_CPUF_SSE4_1 = $400;
  AVS_CPUF_AVX = $800;
  AVS_CPUF_SSE4_2 = $1000;
  AVS_CPUF_AVX2 = $2000;
  AVS_CPUF_FMA3 = $4000;
  AVS_CPUF_F16C = $8000;
  AVS_CPUF_MOVBE = $10000;
  AVS_CPUF_POPCNT = $20000;
  AVS_CPUF_AES = $40000;
  AVS_CPUF_FMA4 = $80000;
  AVS_CPUF_AVX512F = $100000;
  AVS_CPUF_AVX512DQ = $200000;
  AVS_CPUF_AVX512PF = $400000;
  AVS_CPUF_AVX512ER = $800000;
  AVS_CPUF_AVX512CD = $1000000;
  AVS_CPUF_AVX512BW = $2000000;
  AVS_CPUF_AVX512VL = $4000000;
  AVS_CPUF_AVX512IFMA = $8000000;
  AVS_CPUF_AVX512VBMI = $10000000;
  AVS_CPUF_AVX512_BASE = $20000000;
  AVS_CPUF_AVX512_FAST = $40000000;

// CPU Flags (64-bit)
  AVS_CPUF_AVX512VNNI = int64($00100000000);
  AVS_CPUF_AVX512VBMI2 = int64($00200000000);
  AVS_CPUF_AVX512BITALG = int64($00400000000);
  AVS_CPUF_AVX512VPOPCNTDQ = int64($00800000000);
  AVS_CPUF_AVX512FP16 = int64($01000000000);
  AVS_CPUF_AVX512BF16 = int64($02000000000);

  // ARMv8-A CPU Flags
  AVS_CPUF_ARM_NEON = $01;
  AVS_CPUF_ARM_DOTPROD = $02;
  AVS_CPUF_ARM_SVE2 = $04;
  AVS_CPUF_ARM_I8MM = $08;
  AVS_CPUF_ARM_SVE2_1 = $10;

type
{$IFDEF MSWINDOWS}
  {$DEFINE AVSC_CC := stdcall}
{$ELSE}
  {$DEFINE AVSC_CC := cdecl}
{$ENDIF}
{$IF DEFINED(CPUI386) AND DEFINED(MSWINDOWS)}
  // FPC returns records larger than 4 bytes from stdcall functions through a hidden pointer
  // (Delphi convention), MSVC returns 8-byte structs in EDX:EAX. AVS_Value is 8 bytes here, so
  // the functions returning it are imported with an Int64 result, which both return in EDX:EAX.
  {$DEFINE AVSC_VALUE_RESULT_AS_INT64}
{$ENDIF}

  PAVS_Clip = ^AVS_Clip;
  AVS_Clip = record
  end;

  PAVS_ScriptEnvironment = ^AVS_ScriptEnvironment;
  AVS_ScriptEnvironment = record
  end;

  PAVS_VideoInfo = ^AVS_VideoInfo;
  AVS_VideoInfo = record
    Width, Height: cint;
    fps_numerator, fps_denominator: cuint;
    num_frames: cint;
    pixel_type: cint;
    audio_samples_per_second: cint;
    sample_type: cint;
    num_audio_samples: cint64;
    nchannels: cint;
    image_type: cint;
  end;

  PAVS_VideoFrameBuffer = ^AVS_VideoFrameBuffer;
  AVS_VideoFrameBuffer = record
    Data: pbyte;
    data_size: cint;
    sequence_number: clong;
    refcount: clong;
    device: Pointer;
  end;

  PPAVS_VideoFrame = ^PAVS_VideoFrame;
  PAVS_VideoFrame = ^AVS_VideoFrame;
  AVS_VideoFrame = record
    _refcount: clong;
    _vfb: PAVS_VideoFrameBuffer;
    _offset: cint;
    _pitch, _row_size, _height: cint;
    _offsetU, _offsetV: cint;
    _pitchUV: cint;
    _row_sizeUV, _heightUV: cint;
    _offsetA: cint;
    _pitchA, _row_sizeA: cint;
    _properties: Pointer;
    _pixel_type: cint;
  end;

  PAVS_Map = ^AVS_Map;
  AVS_Map = record
    Data: Pointer;
  end;

  PAVS_Value = ^AVS_Value;
  AVS_Value = record
    vtype: cshort;
    array_size: cshort;
    d: record
      case integer of
        0: (clip: Pointer);
        1: (boolean: cchar);
        2: (integer: cint);
        3: (floating_pt: cfloat);
        4: (string_: PAnsiChar);
        5: (array_: PAVS_Value);
        6: (function_: Pointer);
{$IFDEF CPU64}
        7: (longlong: cint64);
        8: (double_pt: cdouble);
{$ELSE}
        7: (longlong_ptr: pcint64);
        8: (double_pt_ptr: pcdouble);
{$ENDIF}
      end;
  end;

  // AviSynth never calls an AVS_ApplyFunc directly, avs_add_function registers it through a thunk
  // (see its implementation)
  AVS_ApplyFunc = function(env: PAVS_ScriptEnvironment; args: AVS_Value; user_data: Pointer): AVS_Value; AVSC_CC;
  AVS_ApplyFuncR = procedure(env: PAVS_ScriptEnvironment; ret: PAVS_Value; args: AVS_Value; user_data: Pointer); AVSC_CC;
  AVS_ShutdownFunc = procedure(user_data: Pointer; env: PAVS_ScriptEnvironment); AVSC_CC;

  PPAVS_FilterInfo = ^PAVS_FilterInfo;
  PAVS_FilterInfo = ^AVS_FilterInfo;

  TGetFrameFunc = function(fi: PAVS_FilterInfo; n: cint): PAVS_VideoFrame; AVSC_CC;
  TGetParityFunc = function(fi: PAVS_FilterInfo; n: cint): cint; AVSC_CC;
  TGetAudioFunc = function(fi: PAVS_FilterInfo; buf: Pointer; start, Count: cint64): cint; AVSC_CC;
  TSetCacheHintsFunc = function(fi: PAVS_FilterInfo; cachehints, frame_range: cint): cint; AVSC_CC;
  TFreeFilterFunc = procedure(fi: PAVS_FilterInfo); AVSC_CC;

  AVS_FilterInfo = record
    child: PAVS_Clip;
    vi: AVS_VideoInfo;
    env: PAVS_ScriptEnvironment;
    get_frame: TGetFrameFunc;
    get_parity: TGetParityFunc;
    get_audio: TGetAudioFunc;
    set_cache_hints: TSetCacheHintsFunc;
    free_filter: TFreeFilterFunc;
    error: PAnsiChar;
    user_data: Pointer;
  end;

const
  avs_void: AVS_Value = (vtype: Ord('v'); array_size: 0; d: (clip: nil));

// ============================================================================
// API functions (external DLL bindings)
// ============================================================================

// VideoInfo API
function avs_is_yv24(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_yv16(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_yv12(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_yv411(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_y8(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_plane_width_subsampling(const p: PAVS_VideoInfo; plane: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_plane_height_subsampling(const p: PAVS_VideoInfo; plane: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_bits_per_pixel(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_bytes_from_pixels(const p: PAVS_VideoInfo; pixels: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_row_size(const p: PAVS_VideoInfo; plane: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_bmp_size(const vi: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_color_space(const p: PAVS_VideoInfo; c_space: cint): cint; AVSC_CC; external AVISYNTH_LIB;

// AviSynth+ VideoInfo extension
function avs_is_rgb48(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_rgb64(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_yuv444p16(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_yuv422p16(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_yuv420p16(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_y16(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_yuv444ps(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_yuv422ps(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_yuv420ps(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_y32(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_444(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_422(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_420(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_y(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_yuva(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_planar_rgb(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_planar_rgba(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_num_components(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_component_size(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_bits_per_component(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;

// V10 Channel mask
// C99 bool is 1 byte (Boolean); ctypes.cbool is a 4-byte LongBool
function avs_is_channel_mask_known(const p: PAVS_VideoInfo): Boolean; AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_channel_mask(const p: PAVS_VideoInfo; isChannelMaskKnown: Boolean; dwChannelMask: cuint); AVSC_CC; external AVISYNTH_LIB;
function avs_get_channel_mask(const p: PAVS_VideoInfo): cuint; AVSC_CC; external AVISYNTH_LIB;

// V13 Pixel formats
function avs_is_440(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_ya(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_410(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_411(const p: PAVS_VideoInfo): cint; AVSC_CC; external AVISYNTH_LIB;

// VideoFrame API
function avs_get_pitch_p(const p: PAVS_VideoFrame; plane: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_row_size_p(const p: PAVS_VideoFrame; plane: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_height_p(const p: PAVS_VideoFrame; plane: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_read_ptr_p(const p: PAVS_VideoFrame; plane: cint): pbyte; AVSC_CC; external AVISYNTH_LIB;
function avs_is_writable(const p: PAVS_VideoFrame): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_is_property_writable(const p: PAVS_VideoFrame): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_write_ptr_p(const p: PAVS_VideoFrame; plane: cint): pbyte; AVSC_CC; external AVISYNTH_LIB;
procedure avs_release_video_frame(p: PAVS_VideoFrame); AVSC_CC; external AVISYNTH_LIB;
function avs_copy_video_frame(p: PAVS_VideoFrame): PAVS_VideoFrame; AVSC_CC; external AVISYNTH_LIB;
function avs_video_frame_get_pixel_type(const p: PAVS_VideoFrame): cint; AVSC_CC; external AVISYNTH_LIB;
procedure avs_video_frame_amend_pixel_type(p: PAVS_VideoFrame; new_pixel_type: cint); AVSC_CC; external AVISYNTH_LIB;

// AVS_Value API
procedure avs_copy_value(dest: PAVS_Value; src: AVS_Value); AVSC_CC; external AVISYNTH_LIB;
procedure avs_release_value(v: AVS_Value); AVSC_CC; external AVISYNTH_LIB;
function avs_take_clip(v: AVS_Value; env: PAVS_ScriptEnvironment): PAVS_Clip; AVSC_CC; external AVISYNTH_LIB;
function avs_val_defined(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_is_clip(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_is_bool(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_is_int(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_is_long_strict(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_is_float(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_is_floatf_strict(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_is_string(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_is_array(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_is_error(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_is_function(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_val_get_type(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_as_bool(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_as_clip(v: AVS_Value; env: PAVS_ScriptEnvironment): PAVS_Clip; AVSC_CC; external AVISYNTH_LIB;
function avs_get_as_int(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_as_long(v: AVS_Value): cint64; AVSC_CC; external AVISYNTH_LIB;
function avs_get_as_string(v: AVS_Value): PAnsiChar; AVSC_CC; external AVISYNTH_LIB;
function avs_get_as_float(v: AVS_Value): cdouble; AVSC_CC; external AVISYNTH_LIB;
function avs_get_as_error(v: AVS_Value): PAnsiChar; AVSC_CC; external AVISYNTH_LIB;
function avs_get_as_array(v: AVS_Value): PAVS_Value; AVSC_CC; external AVISYNTH_LIB;
function avs_get_array_elt(v: AVS_Value; index: cint): AVS_Value; {$IFNDEF AVSC_VALUE_RESULT_AS_INT64}AVSC_CC; external AVISYNTH_LIB;{$ENDIF}
function avs_get_array_size(v: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_to_clip(v: PAVS_Value; c: PAVS_Clip); AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_to_error(v: PAVS_Value; v0: PAnsiChar); AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_to_bool(v: PAVS_Value; v0: cint); AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_to_int(v: PAVS_Value; v0: cint); AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_to_float(v: PAVS_Value; v0: cfloat); AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_to_string(v: PAVS_Value; v0: PAnsiChar); AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_to_double(v: PAVS_Value; d: cdouble); AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_to_long(v: PAVS_Value; l: cint64); AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_to_array(v: PAVS_Value; src: PAVS_Value; size: cint); AVSC_CC; external AVISYNTH_LIB;
procedure avs_set_to_void(v: PAVS_Value); AVSC_CC; external AVISYNTH_LIB;

// AVS_Clip API
procedure avs_release_clip(c: PAVS_Clip); AVSC_CC; external AVISYNTH_LIB;
function avs_copy_clip(c: PAVS_Clip): PAVS_Clip; AVSC_CC; external AVISYNTH_LIB;
function avs_clip_get_error(c: PAVS_Clip): PAnsiChar; AVSC_CC; external AVISYNTH_LIB;
function avs_get_video_info(c: PAVS_Clip): PAVS_VideoInfo; AVSC_CC; external AVISYNTH_LIB;
function avs_get_version(c: PAVS_Clip): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_frame(c: PAVS_Clip; n: cint): PAVS_VideoFrame; AVSC_CC; external AVISYNTH_LIB;
function avs_get_parity(c: PAVS_Clip; n: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_audio(c: PAVS_Clip; buf: Pointer; start, Count: cint64): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_set_cache_hints(c: PAVS_Clip; cachehints, frame_range: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_new_c_filter(e: PAVS_ScriptEnvironment; fi: PPAVS_FilterInfo; child: AVS_Value; store_child: cint): PAVS_Clip; AVSC_CC; external AVISYNTH_LIB;

// ScriptEnvironment API
function avs_get_error(e: PAVS_ScriptEnvironment): PAnsiChar; AVSC_CC; external AVISYNTH_LIB;
function avs_get_cpu_flags(e: PAVS_ScriptEnvironment): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_cpu_flags_ex(e: PAVS_ScriptEnvironment): cint64; AVSC_CC; external AVISYNTH_LIB;
function avs_check_version(e: PAVS_ScriptEnvironment; version: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_save_string(e: PAVS_ScriptEnvironment; const s: PAnsiChar; length: cint): PAnsiChar; AVSC_CC; external AVISYNTH_LIB;
function avs_sprintf(e: PAVS_ScriptEnvironment; const fmt: PAnsiChar): PAnsiChar; cdecl; varargs; external AVISYNTH_LIB;
// Implemented with avs_add_function_r, needs interface V11 (AviSynth+ 3.7.4).
// Returns -1 when more than 255 different apply/user_data pairs are registered.
function avs_add_function(e: PAVS_ScriptEnvironment; const Name, params: PAnsiChar; apply: AVS_ApplyFunc; user_data: Pointer): cint;
function avs_add_function_r(e: PAVS_ScriptEnvironment; const Name, params: PAnsiChar; apply: AVS_ApplyFuncR; user_data: Pointer): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_function_exists(e: PAVS_ScriptEnvironment; const Name: PAnsiChar): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_invoke(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; args: AVS_Value; const arg_names: PPAnsiChar): AVS_Value; {$IFNDEF AVSC_VALUE_RESULT_AS_INT64}AVSC_CC; external AVISYNTH_LIB;{$ENDIF}
function avs_invoke_try(e: PAVS_ScriptEnvironment; Result: PAVS_Value; const Name: PAnsiChar; args: AVS_Value; const arg_names: PPAnsiChar): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_invoke2(e: PAVS_ScriptEnvironment; implicit_last: AVS_Value; const Name: PAnsiChar; args: AVS_Value; const arg_names: PPAnsiChar): AVS_Value; {$IFNDEF AVSC_VALUE_RESULT_AS_INT64}AVSC_CC; external AVISYNTH_LIB;{$ENDIF}
function avs_invoke2_try(e: PAVS_ScriptEnvironment; Result: PAVS_Value; implicit_last: AVS_Value; const Name: PAnsiChar; args: AVS_Value; const arg_names: PPAnsiChar): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_invoke3(e: PAVS_ScriptEnvironment; implicit_last: AVS_Value; func: AVS_Value; args: AVS_Value; const arg_names: PPAnsiChar): AVS_Value; {$IFNDEF AVSC_VALUE_RESULT_AS_INT64}AVSC_CC; external AVISYNTH_LIB;{$ENDIF}
function avs_invoke3_try(e: PAVS_ScriptEnvironment; Result: PAVS_Value; implicit_last: AVS_Value; func: AVS_Value; args: AVS_Value; const arg_names: PPAnsiChar): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_var(e: PAVS_ScriptEnvironment; const Name: PAnsiChar): AVS_Value; {$IFNDEF AVSC_VALUE_RESULT_AS_INT64}AVSC_CC; external AVISYNTH_LIB;{$ENDIF}
function avs_set_var(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; val: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
// val by value: with stdcall, FPC would pass a "const" record by reference
function avs_set_global_var(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; val: AVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_new_video_frame_a(e: PAVS_ScriptEnvironment; const vi: PAVS_VideoInfo; align: cint): PAVS_VideoFrame; AVSC_CC; external AVISYNTH_LIB;
function avs_make_writable(e: PAVS_ScriptEnvironment; pvf: PPAVS_VideoFrame): cint; AVSC_CC; external AVISYNTH_LIB;
procedure avs_apply_message(e: PAVS_ScriptEnvironment; pvf: PPAVS_VideoFrame; const vi: PAVS_VideoInfo; const message: PAnsiChar; size, textcolor, halocolor, bgcolor: cint); AVSC_CC; external AVISYNTH_LIB;
function avs_make_property_writable(e: PAVS_ScriptEnvironment; pvf: PPAVS_VideoFrame): cint; AVSC_CC; external AVISYNTH_LIB;
procedure avs_bit_blt(e: PAVS_ScriptEnvironment; dstp: pbyte; dst_pitch: cint; const srcp: pbyte; src_pitch, row_size, Height: cint); AVSC_CC; external AVISYNTH_LIB;
procedure avs_at_exit(e: PAVS_ScriptEnvironment; func: AVS_ShutdownFunc; user_data: Pointer); AVSC_CC; external AVISYNTH_LIB;
function avs_subframe(e: PAVS_ScriptEnvironment; src: PAVS_VideoFrame; rel_offset, new_pitch, new_row_size, new_height: cint): PAVS_VideoFrame; AVSC_CC; external AVISYNTH_LIB;
function avs_subframe_planar(e: PAVS_ScriptEnvironment; src: PAVS_VideoFrame; rel_offset, new_pitch, new_row_size, new_height, rel_offsetU, rel_offsetV, new_pitchUV: cint): PAVS_VideoFrame; AVSC_CC; external AVISYNTH_LIB;
function avs_set_memory_max(e: PAVS_ScriptEnvironment; mem: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_set_working_dir(e: PAVS_ScriptEnvironment; const newdir: PAnsiChar): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_acquire_global_lock(e: PAVS_ScriptEnvironment; const Name: PAnsiChar): cint; AVSC_CC; external AVISYNTH_LIB;
procedure avs_release_global_lock(e: PAVS_ScriptEnvironment; const Name: PAnsiChar); AVSC_CC; external AVISYNTH_LIB;
function avs_create_script_environment(version: cint): PAVS_ScriptEnvironment; AVSC_CC; external AVISYNTH_LIB;
procedure avs_delete_script_environment(e: PAVS_ScriptEnvironment); AVSC_CC; external AVISYNTH_LIB;

// V8+ Interface & Frame properties API
function avs_subframe_planar_a(e: PAVS_ScriptEnvironment; src: PAVS_VideoFrame; rel_offset, new_pitch, new_row_size, new_height, rel_offsetU, rel_offsetV, new_pitchUV, rel_offsetA: cint): PAVS_VideoFrame; AVSC_CC; external AVISYNTH_LIB;
procedure avs_copy_frame_props(p: PAVS_ScriptEnvironment; const src: PAVS_VideoFrame; dst: PAVS_VideoFrame); AVSC_CC; external AVISYNTH_LIB;
function avs_get_frame_props_ro(p: PAVS_ScriptEnvironment; const frame: PAVS_VideoFrame): PAVS_Map; AVSC_CC; external AVISYNTH_LIB;
function avs_get_frame_props_rw(p: PAVS_ScriptEnvironment; frame: PAVS_VideoFrame): PAVS_Map; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_num_keys(p: PAVS_ScriptEnvironment; const map: PAVS_Map): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_key(p: PAVS_ScriptEnvironment; const map: PAVS_Map; index: cint): PAnsiChar; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_num_elements(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_type(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar): cchar; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_int(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; index: cint; error: pcint): cint64; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_float(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; index: cint; error: pcint): cdouble; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_data(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; index: cint; error: pcint): PAnsiChar; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_data_size(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; index: cint; error: pcint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_data_type_hint(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; index: cint; error: pcint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_clip(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; index: cint; error: pcint): PAVS_Clip; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_frame(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; index: cint; error: pcint): PAVS_VideoFrame; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_int_saturated(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; index: cint; error: pcint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_float_saturated(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; index: cint; error: pcint): cfloat; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_delete_key(p: PAVS_ScriptEnvironment; map: PAVS_Map; const key: PAnsiChar): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_set_int(p: PAVS_ScriptEnvironment; map: PAVS_Map; const key: PAnsiChar; i: cint64; append: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_set_float(p: PAVS_ScriptEnvironment; map: PAVS_Map; const key: PAnsiChar; d: cdouble; append: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_set_data(p: PAVS_ScriptEnvironment; map: PAVS_Map; const key: PAnsiChar; const d: PAnsiChar; length, append: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_set_data_h(p: PAVS_ScriptEnvironment; map: PAVS_Map; const key: PAnsiChar; const d: PAnsiChar; length, _type, append: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_set_clip(p: PAVS_ScriptEnvironment; map: PAVS_Map; const key: PAnsiChar; clip: PAVS_Clip; append: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_set_frame(p: PAVS_ScriptEnvironment; map: PAVS_Map; const key: PAnsiChar; const frame: PAVS_VideoFrame; append: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_int_array(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; error: pcint): pcint64; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_get_float_array(p: PAVS_ScriptEnvironment; const map: PAVS_Map; const key: PAnsiChar; error: pcint): pcdouble; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_set_int_array(p: PAVS_ScriptEnvironment; map: PAVS_Map; const key: PAnsiChar; const i: pcint64; size: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_prop_set_float_array(p: PAVS_ScriptEnvironment; map: PAVS_Map; const key: PAnsiChar; const d: pcdouble; size: cint): cint; AVSC_CC; external AVISYNTH_LIB;
procedure avs_clear_map(p: PAVS_ScriptEnvironment; map: PAVS_Map); AVSC_CC; external AVISYNTH_LIB;
function avs_create_map(p: PAVS_ScriptEnvironment): PAVS_Map; AVSC_CC; external AVISYNTH_LIB;
procedure avs_free_map(p: PAVS_ScriptEnvironment; map: PAVS_Map); AVSC_CC; external AVISYNTH_LIB;
function avs_new_video_frame_p(e: PAVS_ScriptEnvironment; const vi: PAVS_VideoInfo; const prop_src: PAVS_VideoFrame): PAVS_VideoFrame; AVSC_CC; external AVISYNTH_LIB;
function avs_new_video_frame_p_a(e: PAVS_ScriptEnvironment; const vi: PAVS_VideoInfo; const prop_src: PAVS_VideoFrame; align: cint): PAVS_VideoFrame; AVSC_CC; external AVISYNTH_LIB;
function avs_get_env_property(e: PAVS_ScriptEnvironment; avs_aep_prop: cint): csize_t; AVSC_CC; external AVISYNTH_LIB;
function avs_pool_allocate(e: PAVS_ScriptEnvironment; nBytes, alignment: csize_t; avs_alloc_type: cint): Pointer; AVSC_CC; external AVISYNTH_LIB;
procedure avs_pool_free(e: PAVS_ScriptEnvironment; ptr: Pointer); AVSC_CC; external AVISYNTH_LIB;
function avs_get_var_try(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; val: PAVS_Value): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_var_bool(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; def: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_var_int(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; def: cint): cint; AVSC_CC; external AVISYNTH_LIB;
function avs_get_var_double(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; def: cdouble): cdouble; AVSC_CC; external AVISYNTH_LIB;
function avs_get_var_string(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; const def: PAnsiChar): PAnsiChar; AVSC_CC; external AVISYNTH_LIB;
function avs_get_var_long(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; def: cint64): cint64; AVSC_CC; external AVISYNTH_LIB;

// ============================================================================
// Inline auxiliary functions
// ============================================================================
function avs_has_video(const p: PAVS_VideoInfo): cint; inline;
function avs_has_audio(const p: PAVS_VideoInfo): cint; inline;
function avs_is_rgb(const p: PAVS_VideoInfo): cint; inline;
function avs_is_rgb24(const p: PAVS_VideoInfo): cint; inline;
function avs_is_rgb32(const p: PAVS_VideoInfo): cint; inline;
function avs_is_yuv(const p: PAVS_VideoInfo): cint; inline;
function avs_is_yuy2(const p: PAVS_VideoInfo): cint; inline;
function avs_is_property(const p: PAVS_VideoInfo; prop: cint): cint; inline;
function avs_is_planar(const p: PAVS_VideoInfo): cint; inline;
function avs_is_field_based(const p: PAVS_VideoInfo): cint; inline;
function avs_is_parity_known(const p: PAVS_VideoInfo): cint; inline;
function avs_is_bff(const p: PAVS_VideoInfo): cint; inline;
function avs_is_tff(const p: PAVS_VideoInfo): cint; inline;
function avs_samples_per_second(const p: PAVS_VideoInfo): cint; inline;
function avs_bytes_per_channel_sample(const p: PAVS_VideoInfo): cint; inline;
function avs_bytes_per_audio_sample(const p: PAVS_VideoInfo): cint; inline;
function avs_audio_samples_from_frames(const p: PAVS_VideoInfo; frames: cint64): cint64; inline;
function avs_frames_from_audio_samples(const p: PAVS_VideoInfo; samples: cint64): cint; inline;
function avs_audio_samples_from_bytes(const p: PAVS_VideoInfo; bytes: cint64): cint64; inline;
function avs_bytes_from_audio_samples(const p: PAVS_VideoInfo; samples: cint64): cint64; inline;
function avs_audio_channels(const p: PAVS_VideoInfo): cint; inline;
function avs_sample_type(const p: PAVS_VideoInfo): cint; inline;
procedure avs_set_property(p: PAVS_VideoInfo; prop: cint); inline;
procedure avs_clear_property(p: PAVS_VideoInfo; prop: cint); inline;
procedure avs_set_field_based(p: PAVS_VideoInfo; isfieldbased: cint); inline;
procedure avs_set_fps(p: PAVS_VideoInfo; numerator, denominator: cuint); inline;
function avs_is_same_colorspace(const x, y: PAVS_VideoInfo): cint; inline;
function avs_defined(v: AVS_Value): cint; inline;
function avs_is_clip(v: AVS_Value): cint; inline;
function avs_is_bool(v: AVS_Value): cint; inline;
function avs_is_int(v: AVS_Value): cint; inline;
function avs_is_long_strict(v: AVS_Value): cint; inline;
function avs_is_float(v: AVS_Value): cint; inline;
function avs_is_floatf_strict(v: AVS_Value): cint; inline;
function avs_is_string(v: AVS_Value): cint; inline;
function avs_is_array(v: AVS_Value): cint; inline;
function avs_is_error(v: AVS_Value): cint; inline;
function avs_as_bool(v: AVS_Value): cint; inline;
function avs_as_int(v: AVS_Value): cint; inline;
function avs_as_long(v: AVS_Value): cint64; inline;
function avs_as_string(v: AVS_Value): PAnsiChar; inline;
function avs_as_float(v: AVS_Value): cdouble; inline;
function avs_as_error(v: AVS_Value): PAnsiChar; inline;
function avs_as_array(v: AVS_Value): PAVS_Value; inline;
function avs_array_size(v: AVS_Value): cint; inline;
function avs_array_elt(v: AVS_Value; index: cint): AVS_Value; inline;
function avs_new_value_bool(v0: cint): AVS_Value; inline;
function avs_new_value_int(v0: cint): AVS_Value; inline;
function avs_new_value_string(const v0: PAnsiChar): AVS_Value; inline;
function avs_new_value_float(v0: cfloat): AVS_Value; inline;
function avs_new_value_error(const v0: PAnsiChar): AVS_Value; inline;
function avs_new_value_array(v0: PAVS_Value; size: cint): AVS_Value; inline;
function avs_new_value_clip(v0: PAVS_Clip): AVS_Value; inline;
function avs_new_video_frame(env: PAVS_ScriptEnvironment; const vi: PAVS_VideoInfo): PAVS_VideoFrame; inline;
function avs_new_frame(env: PAVS_ScriptEnvironment; const vi: PAVS_VideoInfo): PAVS_VideoFrame; inline;

implementation

{$IFDEF AVSC_VALUE_RESULT_AS_INT64}
type
  TAVS_ValueBits = record
    case integer of
      0: (v: AVS_Value);
      1: (i: Int64);
  end;

function avs_get_array_elt_i64(v: AVS_Value; index: cint): Int64; AVSC_CC; external AVISYNTH_LIB name 'avs_get_array_elt';
function avs_invoke_i64(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; args: AVS_Value; const arg_names: PPAnsiChar): Int64; AVSC_CC; external AVISYNTH_LIB name 'avs_invoke';
function avs_invoke2_i64(e: PAVS_ScriptEnvironment; implicit_last: AVS_Value; const Name: PAnsiChar; args: AVS_Value; const arg_names: PPAnsiChar): Int64; AVSC_CC; external AVISYNTH_LIB name 'avs_invoke2';
function avs_invoke3_i64(e: PAVS_ScriptEnvironment; implicit_last: AVS_Value; func: AVS_Value; args: AVS_Value; const arg_names: PPAnsiChar): Int64; AVSC_CC; external AVISYNTH_LIB name 'avs_invoke3';
function avs_get_var_i64(e: PAVS_ScriptEnvironment; const Name: PAnsiChar): Int64; AVSC_CC; external AVISYNTH_LIB name 'avs_get_var';

function avs_get_array_elt(v: AVS_Value; index: cint): AVS_Value;
var
  r: TAVS_ValueBits;
begin
  r.i := avs_get_array_elt_i64(v, index);
  Result := r.v;
end;

function avs_invoke(e: PAVS_ScriptEnvironment; const Name: PAnsiChar; args: AVS_Value; const arg_names: PPAnsiChar): AVS_Value;
var
  r: TAVS_ValueBits;
begin
  r.i := avs_invoke_i64(e, Name, args, arg_names);
  Result := r.v;
end;

function avs_invoke2(e: PAVS_ScriptEnvironment; implicit_last: AVS_Value; const Name: PAnsiChar; args: AVS_Value; const arg_names: PPAnsiChar): AVS_Value;
var
  r: TAVS_ValueBits;
begin
  r.i := avs_invoke2_i64(e, implicit_last, Name, args, arg_names);
  Result := r.v;
end;

function avs_invoke3(e: PAVS_ScriptEnvironment; implicit_last: AVS_Value; func: AVS_Value; args: AVS_Value; const arg_names: PPAnsiChar): AVS_Value;
var
  r: TAVS_ValueBits;
begin
  r.i := avs_invoke3_i64(e, implicit_last, func, args, arg_names);
  Result := r.v;
end;

function avs_get_var(e: PAVS_ScriptEnvironment; const Name: PAnsiChar): AVS_Value;
var
  r: TAVS_ValueBits;
begin
  r.i := avs_get_var_i64(e, Name);
  Result := r.v;
end;
{$ENDIF}

// avs_add_function
// AviSynth calls a thunk registered with avs_add_function_r (result through a pointer), the thunk
// calls the AVS_ApplyFunc. FPC cannot return an AVS_Value from a callback the way MSVC-built
// AviSynth expects: on Win32 it uses a hidden pointer instead of EDX:EAX, on Win64 (FPC 3.2.2) it
// does not return the result address in RAX.
// The user_data given to AviSynth is a key with a unique, nonzero lowest byte: AviSynth+ V11-V13
// (MSVC builds) could mix up the callbacks of functions whose user_data was equal up to its first
// zero byte, see the notes in avisynth_c.h.
const
  AVS_MAX_APPLY_THUNKS = 255;

var
  ApplyThunks: array[1..AVS_MAX_APPLY_THUNKS] of record
    apply: AVS_ApplyFunc;
    user_data: Pointer;
  end;
  ApplyThunkCount: Longint = 0;
  ApplyThunkLock: Longint = 0;
  ApplyThunkKeys: array[0..511] of Byte; // key i is the 256-aligned address in here plus i

function ApplyThunkKeyBase: PtrUInt; inline;
begin
  Result := (PtrUInt(@ApplyThunkKeys[0]) + 255) and not PtrUInt(255);
end;

procedure avs_apply_func_thunk(env: PAVS_ScriptEnvironment; ret: PAVS_Value; args: AVS_Value; user_data: Pointer); AVSC_CC;
var
  i: PtrUInt;
begin
  i := PtrUInt(user_data) - ApplyThunkKeyBase;
  ret^ := ApplyThunks[i].apply(env, args, ApplyThunks[i].user_data);
end;

function avs_add_function(e: PAVS_ScriptEnvironment; const Name, params: PAnsiChar; apply: AVS_ApplyFunc; user_data: Pointer): cint;
var
  i: Longint;
begin
  // find or add the apply/user_data pair, the same pair (e.g. registered again in another
  // script environment) gets the same key
  while InterlockedCompareExchange(ApplyThunkLock, 1, 0) <> 0 do
    ThreadSwitch;
  i := 1;
  while (i <= ApplyThunkCount) and
        not ((Pointer(ApplyThunks[i].apply) = Pointer(apply)) and (ApplyThunks[i].user_data = user_data)) do
    Inc(i);
  if (i > ApplyThunkCount) and (i <= AVS_MAX_APPLY_THUNKS) then
  begin
    ApplyThunks[i].apply := apply;
    ApplyThunks[i].user_data := user_data;
    ApplyThunkCount := i;
  end;
  InterlockedExchange(ApplyThunkLock, 0);
  if i > AVS_MAX_APPLY_THUNKS then
    Exit(-1);
  Result := avs_add_function_r(e, Name, params, @avs_apply_func_thunk, Pointer(ApplyThunkKeyBase + PtrUInt(i)));
end;

function avs_has_video(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord(p^.Width <> 0);
end;

function avs_has_audio(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord(p^.audio_samples_per_second <> 0);
end;

function avs_is_rgb(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord((p^.pixel_type and AVS_CS_BGR) <> 0);
end;

function avs_is_rgb24(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord(((p^.pixel_type and AVS_CS_BGR24) = AVS_CS_BGR24) and ((p^.pixel_type and AVS_CS_SAMPLE_BITS_MASK) = AVS_CS_SAMPLE_BITS_8));
end;

function avs_is_rgb32(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord(((p^.pixel_type and AVS_CS_BGR32) = AVS_CS_BGR32) and ((p^.pixel_type and AVS_CS_SAMPLE_BITS_MASK) = AVS_CS_SAMPLE_BITS_8));
end;

function avs_is_yuv(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord((p^.pixel_type and AVS_CS_YUV) <> 0);
end;

function avs_is_yuy2(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord((p^.pixel_type and AVS_CS_YUY2) = AVS_CS_YUY2);
end;

function avs_is_property(const p: PAVS_VideoInfo; prop: cint): cint;
begin
  Result := Ord((p^.image_type and prop) = prop);
end;

function avs_is_planar(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord((p^.pixel_type and AVS_CS_PLANAR) <> 0);
end;

function avs_is_field_based(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord((p^.image_type and AVS_IT_FIELDBASED) <> 0);
end;

function avs_is_parity_known(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord(((p^.image_type and AVS_IT_FIELDBASED) <> 0) and ((p^.image_type and (AVS_IT_BFF or AVS_IT_TFF)) <> 0));
end;

function avs_is_bff(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord((p^.image_type and AVS_IT_BFF) <> 0);
end;

function avs_is_tff(const p: PAVS_VideoInfo): cint;
begin
  Result := Ord((p^.image_type and AVS_IT_TFF) <> 0);
end;

function avs_samples_per_second(const p: PAVS_VideoInfo): cint;
begin
  Result := p^.audio_samples_per_second;
end;

function avs_bytes_per_channel_sample(const p: PAVS_VideoInfo): cint;
begin
  case p^.sample_type of
    AVS_SAMPLE_INT8: Result := SizeOf(cint8);
    AVS_SAMPLE_INT16: Result := SizeOf(cint16);
    AVS_SAMPLE_INT24: Result := 3;
    AVS_SAMPLE_INT32: Result := SizeOf(cint32);
    AVS_SAMPLE_FLOAT: Result := SizeOf(cfloat);
  else
    Result := 0;
  end;
end;

function avs_bytes_per_audio_sample(const p: PAVS_VideoInfo): cint;
begin
  Result := p^.nchannels * avs_bytes_per_channel_sample(p);
end;

function avs_audio_samples_from_frames(const p: PAVS_VideoInfo; frames: cint64): cint64;
begin
  Result := (frames * p^.audio_samples_per_second * p^.fps_denominator) div p^.fps_numerator;
end;

function avs_frames_from_audio_samples(const p: PAVS_VideoInfo; samples: cint64): cint;
begin
  Result := cint((samples * cint64(p^.fps_numerator)) div cint64(p^.fps_denominator) div cint64(p^.audio_samples_per_second));
end;

function avs_audio_samples_from_bytes(const p: PAVS_VideoInfo; bytes: cint64): cint64;
begin
  Result := bytes div avs_bytes_per_audio_sample(p);
end;

function avs_bytes_from_audio_samples(const p: PAVS_VideoInfo; samples: cint64): cint64;
begin
  Result := samples * avs_bytes_per_audio_sample(p);
end;

function avs_audio_channels(const p: PAVS_VideoInfo): cint;
begin
  Result := p^.nchannels;
end;

function avs_sample_type(const p: PAVS_VideoInfo): cint;
begin
  Result := p^.sample_type;
end;

procedure avs_set_property(p: PAVS_VideoInfo; prop: cint);
begin
  p^.image_type := p^.image_type or prop;
end;

procedure avs_clear_property(p: PAVS_VideoInfo; prop: cint);
begin
  p^.image_type := p^.image_type and (not prop);
end;

procedure avs_set_field_based(p: PAVS_VideoInfo; isfieldbased: cint);
begin
  if isfieldbased <> 0
  then p^.image_type := p^.image_type or AVS_IT_FIELDBASED
  else p^.image_type := p^.image_type and (not AVS_IT_FIELDBASED);
end;

procedure avs_set_fps(p: PAVS_VideoInfo; numerator, denominator: cuint);
var
  x, y, t: cuint;
begin
  x := numerator;
  y := denominator;
  while y <> 0 do
  begin
    t := x mod y;
    x := y;
    y := t;
  end;
  p^.fps_numerator := numerator div x;
  p^.fps_denominator := denominator div x;
end;

function avs_is_same_colorspace(const x, y: PAVS_VideoInfo): cint;
begin
  Result := Ord((x^.pixel_type = y^.pixel_type) or ((avs_is_yv12(x) <> 0) and (avs_is_yv12(y) <> 0)));
end;

function avs_defined(v: AVS_Value): cint;
begin
  Result := Ord(v.vtype <> Ord('v'));
end;

function avs_is_clip(v: AVS_Value): cint;
begin
  Result := Ord(v.vtype = Ord('c'));
end;

function avs_is_bool(v: AVS_Value): cint;
begin
  Result := Ord(v.vtype = Ord('b'));
end;

function avs_is_int(v: AVS_Value): cint;
begin
  Result := Ord((v.vtype = Ord('i')) or (v.vtype = Ord('l')));
end;

function avs_is_long_strict(v: AVS_Value): cint;
begin
  Result := Ord(v.vtype = Ord('l'));
end;

function avs_is_float(v: AVS_Value): cint;
begin
  Result := Ord((v.vtype = Ord('d')) or (v.vtype = Ord('f')) or (v.vtype = Ord('i')) or (v.vtype = Ord('l')));
end;

function avs_is_floatf_strict(v: AVS_Value): cint;
begin
  Result := Ord(v.vtype = Ord('f'));
end;

function avs_is_string(v: AVS_Value): cint;
begin
  Result := Ord(v.vtype = Ord('s'));
end;

function avs_is_array(v: AVS_Value): cint;
begin
  Result := Ord(v.vtype = Ord('a'));
end;

function avs_is_error(v: AVS_Value): cint;
begin
  Result := Ord(v.vtype = Ord('e'));
end;

function avs_as_bool(v: AVS_Value): cint;
begin
  Result := Ord(v.d.boolean);
end;

function avs_as_int(v: AVS_Value): cint;
begin
{$IFDEF CPU64}
  if v.vtype = Ord('l')
  then Result := cint(v.d.longlong)
  else Result := v.d.integer;
{$ELSE}
  if v.vtype = Ord('l')
  then Result := cint(v.d.longlong_ptr^)
  else Result := v.d.integer;
{$ENDIF}
end;

function avs_as_long(v: AVS_Value): cint64;
begin
{$IFDEF CPU64}
  if v.vtype = Ord('l')
  then Result := v.d.longlong
  else Result := v.d.integer;
{$ELSE}
  if v.vtype = Ord('l')
  then Result := v.d.longlong_ptr^
  else Result := v.d.integer;
{$ENDIF}
end;

function avs_as_string(v: AVS_Value): PAnsiChar;
begin
  if (avs_is_error(v) <> 0) or (avs_is_string(v) <> 0)
  then Result := v.d.string_
  else Result := nil;
end;

function avs_as_float(v: AVS_Value): cdouble;
begin
  case v.vtype of
    Ord('i'): Result := v.d.integer;
{$IFDEF CPU64}
    Ord('l'): Result := v.d.longlong;
    Ord('d'): Result := v.d.double_pt;
{$ELSE}
    Ord('l'): Result := v.d.longlong_ptr^;
    Ord('d'): Result := v.d.double_pt_ptr^;
{$ENDIF}
  else
    Result := v.d.floating_pt;
  end;
end;

function avs_as_error(v: AVS_Value): PAnsiChar;
begin
  if avs_is_error(v) <> 0
  then Result := v.d.string_
  else Result := nil;
end;

function avs_as_array(v: AVS_Value): PAVS_Value;
begin
  Result := v.d.array_;
end;

function avs_array_size(v: AVS_Value): cint;
begin
  if avs_is_array(v) <> 0
  then Result := v.array_size
  else Result := 1;
end;

function avs_array_elt(v: AVS_Value; index: cint): AVS_Value;
begin
  if avs_is_array(v) <> 0
  then Result := v.d.array_[index]
  else Result := v;
end;

function avs_new_value_bool(v0: cint): AVS_Value;
begin
  Result.vtype := Ord('b');
  Result.array_size := 0;
  if v0 = 0
  then Result.d.boolean := 0  // false
  else Result.d.boolean := 1; // true
end;

function avs_new_value_int(v0: cint): AVS_Value;
begin
  Result.vtype := Ord('i');
  Result.array_size := 0;
  Result.d.integer := v0;
end;

function avs_new_value_string(const v0: PAnsiChar): AVS_Value;
begin
  Result.vtype := Ord('s');
  Result.array_size := 0;
  Result.d.string_ := v0;
end;

function avs_new_value_float(v0: cfloat): AVS_Value;
begin
  Result.vtype := Ord('f');
  Result.array_size := 0;
  Result.d.floating_pt := v0;
end;

function avs_new_value_error(const v0: PAnsiChar): AVS_Value;
begin
  Result.vtype := Ord('e');
  Result.array_size := 0;
  Result.d.string_ := v0;
end;

function avs_new_value_array(v0: PAVS_Value; size: cint): AVS_Value;
begin
  Result.vtype := Ord('a');
  Result.array_size := cshort(size);
  Result.d.array_ := v0;
end;

function avs_new_value_clip(v0: PAVS_Clip): AVS_Value;
begin
  avs_set_to_clip(@Result, v0);
end;

function avs_new_video_frame(env: PAVS_ScriptEnvironment;
  const vi: PAVS_VideoInfo): PAVS_VideoFrame;
begin
  Result := avs_new_video_frame_a(env, vi, AVS_FRAME_ALIGN);
end;

function avs_new_frame(env: PAVS_ScriptEnvironment;
  const vi: PAVS_VideoInfo): PAVS_VideoFrame;
begin
  Result := avs_new_video_frame_a(env, vi, AVS_FRAME_ALIGN);
end;

end.
