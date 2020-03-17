#version 420 compatibility
#define gbuffers_skytextured
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

uniform sampler2D texture;

in vec4 color;
in vec2 uv;

void main() {
    gl_FragData[0] = color * texture2D(texture, uv);
    gl_FragData[6] = vec4(1.0, 1.0, 1.0, 0.0);
    gl_FragData[5] = vec4(1, 0, 0, 1);
}