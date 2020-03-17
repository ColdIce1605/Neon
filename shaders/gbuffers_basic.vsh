#version 420 compatibility
#define gbuffers_basic
#define vsh
#include "/lib/Syntax.glsl"

out vec4 color;
out vec4 texcoord;

out vec3 normal;

void main() {
        texcoord      = gl_TextureMatrix[0] * gl_MultiTexCoord0;

	vec4 position = gl_Vertex;

	gl_Position   = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);

        color         = gl_Color;

        normal        = normalize(gl_NormalMatrix * gl_Normal);
}