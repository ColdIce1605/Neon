#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#define fsh

#include "/cfg/global.scfg"
#include "/cfg/debug.scfg"


//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:01 */

layout (location = 0) out vec4 packedMaterial;
layout (location = 1) out vec4 packedData;

//--// Program //----------------------------------------------------------------------------------------//

#include "/programs/gbuffers/hand.glsl"