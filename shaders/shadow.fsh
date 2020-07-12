#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:01 */

layout (location = 0) out vec4 color;
layout (location = 1) out vec4 normal;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec4 tint;
in vec2 baseUV;
in vec3 vertNormal;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform sampler2D base;

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
	color     = texture(base, baseUV) * tint;
	if (color.a < 0.102) discard; // ~ 26 / 255
	color.rgb = pow(color.rgb, vec3(GAMMA));
	normal    = vec4(vertNormal * 0.5 + 0.5, 1.0);
}
