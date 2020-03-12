#version 420 compatibility
#define composite0
#define fsh
#include "/lib/Syntax.glsl"


/* DRAWBUFFERS:0 */

uniform sampler2D colortex0;

in vec2 texcoord;

layout (location = 0) out vec4 albedo;

void main() {
    albedo = texture(colortex0, texcoord);
    
}