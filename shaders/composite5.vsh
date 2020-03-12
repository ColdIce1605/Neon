#version 420 compatibility
#define composite5
#define vsh
#include "/lib/Syntax.glsl"

out vec2 texcoord;

void main() {
    gl_Position	= ftransform();
    texcoord = gl_MultiTexCoord0.st;
}