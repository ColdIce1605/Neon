#version 420 compatibility

//--// Configuration //----------------------------------------------------------------------------------//

#define vsh

//--// Outputs //----------------------------------------------------------------------------------------//

out mat3 tbnMatrix;
out vec4 tint;
out vec2 baseUV, lmUV;

//--// Inputs //-----------------------------------------------------------------------------------------//

layout (location = 0)  in vec4 vertexPosition;
layout (location = 2)  in vec3 vertexNormal;
layout (location = 3)  in vec4 vertexColor;
layout (location = 8)  in vec2 vertexUV;
layout (location = 9)  in vec2 vertexLightmap;
layout (location = 12) in vec4 vertexTangent;

//--// Program //----------------------------------------------------------------------------------------//

#include "/programs/gbuffers/hand.glsl"