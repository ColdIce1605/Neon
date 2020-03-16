#version 420 compatibility
#define gbuffers_textured
#define vsh
#include "/lib/Syntax.glsl"

out vec2 texcoord;
out vec4 color;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	color = gl_Color;
}