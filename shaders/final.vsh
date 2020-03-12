#version 420 compatibility
#define final
#define vsh
#include "/lib/Syntax.glsl"

out vec2 texcoord;
out vec4 color;

void main() {
    gl_Position	= ftransform();
    texcoord = gl_MultiTexCoord0.st;
	color = gl_Color;
}