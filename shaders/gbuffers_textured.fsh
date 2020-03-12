#version 450 compatibility
#define gbuffers_basic
#define fsh
#define ShaderStage -1
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"

/* DRAWBUFFERS:0 */

layout (location = 0) out vec4 albedo;

uniform sampler2D texture;

in vec2 texcoord;
in vec4 color;

void main() {
    albedo = texture2D(texture, texcoord) * color;
    albedo = vec4(sRGB2L(albedo.rgb), albedo.a);
}