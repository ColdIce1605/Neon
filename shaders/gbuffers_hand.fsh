#version 420 compatibility
#define gbuffers_hand
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/framebuffer.glsl"
#include "/lib/Settings.glsl"

layout (location = 0) out vec4 albedo;
layout (location = 2) out vec4 normal_hand;

uniform sampler2D lightmap;
uniform sampler2D texture;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 color;
in vec3 normal;

void main() {
	vec4 color = texture2D(texture, texcoord) * color;
	color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:0 */
	albedo = color, 1.0; //colortex0
	normal_hand = vec4(normal * 0.5 + 0.5, 1.0);
}