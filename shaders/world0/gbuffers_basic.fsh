#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#define fsh

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:0 */

layout (location = 0) out vec4 packedMaterial;

//--// Program //----------------------------------------------------------------------------------------//

#include "/programs/gbuffers/basic.glsl"
