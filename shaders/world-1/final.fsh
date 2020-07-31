#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#define fsh

#include "/cfg/global.scfg"

#define FINAL

#include "/cfg/bloom.scfg"

const bool colortex4MipmapEnabled = true;

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:0 */

layout (location = 0) out vec3 finalColor;

//--// Program //----------------------------------------------------------------------------------------//

#include "/programs/final/final.glsl"