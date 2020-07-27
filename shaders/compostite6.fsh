#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

#define COMPOSITE 6

#include "/cfg/bloom.scfg"

const bool colortex4MipmapEnabled = true;

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:06 */

layout (location = 0) out vec3 composite;
layout (location = 1) out vec4 temporalBuffer;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;

in float avglum;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform sampler2D colortex4;
uniform sampler2D colortex6;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/debug.glsl"

#include "/lib/preprocess.glsl"

//--//

void main() {
	composite = texture(colortex4, fragCoord).rgb;
	temporalBuffer = vec4(0.0, 0.0, 0.0, avglum);

	debugExit();
}