#version 420 compatibility
#define gbuffers_basic
#define fsh
#include "/lib/Syntax.glsl"

/* DRAWBUFFERS:012 */

layout (location = 0) out vec4 albedo;

uniform sampler2D colortex0;

in vec4 color;
in vec4 texcoord;



/*DRAWBUFFERS:012*/
void main() {
    albedo = texture2D(colortex0, texcoord.st) * color;
}