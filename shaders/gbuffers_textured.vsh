#version 420 compatibility
#define gbuffers_textured
#define vsh
#include "/lib/Syntax.glsl"

out vec2 texcoord;
out vec4 color;

void main() {
    texcoord = gl_MultiTexCoord0.st;
    color = gl_Color;

	gl_Position	= ftransform();
}