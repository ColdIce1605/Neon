#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#define fsh

#include "/cfg/global.scfg"
#include "/cfg/water.scfg"

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:23 */

layout (location = 0) out vec4 data0;
layout (location = 1) out vec4 data1;

//--// Program //----------------------------------------------------------------------------------------//

#include "/programs/gbuffers/transparent.glsl"