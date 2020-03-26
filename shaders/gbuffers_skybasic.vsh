#version 420 compatibility
#define gbuffers_skybasic
#define vsh
#include "/lib/Syntax.glsl"

uniform float timeAngle;

uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform mat4 gbufferModelView;
uniform int worldTime;

out vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
out float isNight;

void main() {

    if (worldTime < 12700 || worldTime > 23250) {
        isNight = 0;
    } 
    else {
        isNight = 1;
    }

	gl_Position = ftransform();
}