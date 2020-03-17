#version 420 compatibility
#define gbuffers_hand
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

uniform sampler2D lightmap;
uniform sampler2D texture;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 color;

void main() {
	vec4 color = texture2D(texture, texcoord) * color;
	color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //colortex0
}