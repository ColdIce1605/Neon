#version 420 compatibility
#define composite5
#define vsh
#include "/lib/Syntax.glsl"

uniform float sunAngle;

#include "/lib/time.glsl";

out vec2 texcoord;
out vec2 screenCoord;

out vec4 timeVector;

void main() {
    gl_Position	= ftransform();

    screenCoord = gl_MultiTexCoord0.st;

	timeVector = CalculateTimeVector();

    texcoord = gl_MultiTexCoord0.st;
}