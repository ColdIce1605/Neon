#version 420 compatibility
#define gbuffers_terrain
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

/* DRAWBUFFERS:01 */

layout (location = 0) out vec4 albedo;
layout (location = 1) out vec4 normal;

uniform sampler2D lightmap;
uniform sampler2D texture;
uniform sampler2D normals;

in vec2 lmcoord;
in vec2 texcoord;

in vec4 color;

in mat3 tbnMatrix;

#define GetTexture(sampler, coord) texture2D(sampler, texcoord)

vec3 calcNormals(vec2 texcoord) {
#ifdef MC_NORMAL_MAP
	vec3 normal = GetTexture(normals, texcoord).xyz;
#else
	vec3 normal = vec3(0.5, 0.5, 1.0);
#endif
	
	normal.xyz = tbnMatrix * normalize(normal.xyz * 2.0 - 1.0);
	
	return normal;
}

void main() {
    vec4 colorSample = texture2D(texture, texcoord) * color;
    colorSample *= texture2D(lightmap, lmcoord); // remove * for whiteworld
    vec3 normalSample = calcNormals(texcoord);


    albedo = vec4((colorSample.rgb), colorSample.a);
    normal = vec4(normalSample, 1.0);
}