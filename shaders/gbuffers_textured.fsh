#version 420 compatibility
#define gbuffers_basic
#define fsh
#define ShaderStage -1
#include "/lib/Syntax.glsl"

/* DRAWBUFFERS:0 */

layout (location = 0) out vec4 albedo;

uniform sampler2D texture;

in vec2 texcoord;
in vec4 color;

vec3 sRGB2L(vec3 sRGBCol) {
	vec3 linearRGBLo  = sRGBCol / 12.92;
	vec3 linearRGBHi  = pow((sRGBCol + 0.055) / 1.055, vec3(2.4));
	vec3 linearRGB    = mix(linearRGBHi, linearRGBLo, lessThanEqual(sRGBCol, vec3(0.04045)));

	return  linearRGB;
}

void main() {
    albedo = texture2D(texture, texcoord) * color;
    albedo = vec4(sRGB2L(albedo.rgb), albedo.a);
}