#version 420 compatibility
#define gbuffers_hand
#define vsh
#include "/lib/Syntax.glsl"

out vec2 lmcoord;
out vec2 texcoord;

out vec3 normal;

out vec4 color;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	normal        = normalize(gl_NormalMatrix * gl_Normal);
	color = gl_Color;
}