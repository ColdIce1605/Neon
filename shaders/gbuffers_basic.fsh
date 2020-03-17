#version 420 compatibility
#define gbuffers_basic
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

/* DRAWBUFFERS:012 */

layout (location = 0) out vec4 albedo;
layout (location = 1) out vec4 normal_basic;

uniform sampler2D colortex0;

in vec4 color;
in vec4 texcoord;

in vec3 normal;

/*DRAWBUFFERS:012*/
void main() {
    albedo = texture2D(colortex0, texcoord.st) * color;
    normal_basic = vec4(normal * 0.5 + 0.5, 1.0);
}