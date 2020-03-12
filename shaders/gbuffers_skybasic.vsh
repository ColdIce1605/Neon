#version 420 compatibility
#define gbuffers_textured
#define vsh
#include "/lib/Syntax.glsl"

out vec2 texcoord;
out vec4 color;
out vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

void main() {
    texcoord = gl_MultiTexCoord0.st;
    color = gl_Color;

	gl_Position	= ftransform();
    starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
}