#version 420 compatibility
#define composite4
#define vsh
#include "/lib/Syntax.glsl"

out vec2 texcoord;
out vec2 screenCoord;

void main() {
    gl_Position	= ftransform();

	screenCoord = gl_MultiTexCoord0.xy;

    texcoord = gl_MultiTexCoord0.st;
}