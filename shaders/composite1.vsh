#version 420 compatibility
#define composite1
#define vsh
#include "/lib/Syntax.glsl"

out vec4 texcoord;

void main() {
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0;
}