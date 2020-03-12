#version 420 compatibility
#define gbuffers_basic
#define fsh
#include "/lib/Syntax.glsl"

/* DRAWBUFFERS:01 */

layout (location = 0) out vec4 albedo;
layout (location = 1) out vec4 normal;

uniform sampler2D texture;
uniform sampler2D normals;

in vec2 texcoord;
in vec4 color;

in mat3 tbnMatrix;

vec3 calcNormals(vec2 coord) {
#ifdef NORMAL_MAPS
	vec3 normal = GetTexture(normals, coord).xyz;
#else
	vec3 normal = vec3(0.5, 0.5, 1.0);
#endif
	
	normal.xyz = tbnMatrix * normalize(normal.xyz * 2.0 - 1.0);
	
	return normal;
}

void main() {
    vec4 colorSample = texture2D(texture, texcoord) * color;
    vec3 normalSample = calcNormals(texcoord);


    albedo = vec4((colorSample.rgb), colorSample.a);
    normal = vec4(normalSample, 1.0);
}