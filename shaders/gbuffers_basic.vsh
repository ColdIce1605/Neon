#version 420 compatibility
#define gbuffers_textured
#define vsh
#include "/lib/Syntax.glsl"

out vec4 color;

void main() {
    color = gl_Color;

	gl_Position	= ftransform();
}