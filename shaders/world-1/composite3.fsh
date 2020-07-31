#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

#define COMPOSITE 3

#include "/cfg/bloom.scfg"

const bool colortex4MipmapEnabled = true;

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:5 */

layout (location = 0) out vec4 bloom;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;

//--// Uniforms //---------------------------------------------------------------------------------------//

#ifdef BLOOM
uniform float viewWidth, viewHeight;

uniform sampler2D colortex4;
#endif

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/preprocess.glsl"

//--//

#ifdef BLOOM
vec4 sampleBloom(sampler2D sampler, vec2 coord, vec2 direction, int lod) {
	if (any(greaterThan(abs(coord - 0.5), vec2(0.5)))) return vec4(0.0);

	const float[5] weights = float[5](0.19947114, 0.29701803, 0.09175428, 0.01098007, 0.00050326);
	const float[5] offsets = float[5](0.00000000, 1.40733340, 3.29421497, 5.20181322, 7.13296424);

	vec2 resolution = textureSize(sampler, lod);

	vec4 bloom = textureLod(sampler, coord, lod) * weights[0];
	for (int i = 1; i < 5; i++) {
		vec2 offset = offsets[i] * direction / resolution;
		bloom += textureLod(sampler, coord + offset, lod) * weights[i];
		bloom += textureLod(sampler, coord - offset, lod) * weights[i];
	}
	return bloom;
}

vec4 calculateBloomTiles() {
	vec2 px = 1.0 / vec2(viewWidth, viewHeight);

	vec4
	bloom  = sampleBloom(colortex4, (fragCoord - vec2(0.000000           , 0.00000            )) * exp2(1), vec2(1.0, 0.0), 1);
	bloom += sampleBloom(colortex4, (fragCoord - vec2(0.000000           , 0.50000 + px.y * 19)) * exp2(2), vec2(1.0, 0.0), 2);
	bloom += sampleBloom(colortex4, (fragCoord - vec2(0.250000 + px.x * 2, 0.50000 + px.y * 19)) * exp2(3), vec2(1.0, 0.0), 3);
	bloom += sampleBloom(colortex4, (fragCoord - vec2(0.250000 + px.x * 2, 0.62500 + px.y * 37)) * exp2(4), vec2(1.0, 0.0), 4);
	bloom += sampleBloom(colortex4, (fragCoord - vec2(0.312500 + px.x * 4, 0.62500 + px.y * 37)) * exp2(5), vec2(1.0, 0.0), 5);
	bloom += sampleBloom(colortex4, (fragCoord - vec2(0.312500 + px.x * 4, 0.65625 + px.y * 55)) * exp2(6), vec2(1.0, 0.0), 6);
	bloom += sampleBloom(colortex4, (fragCoord - vec2(0.328125 + px.x * 6, 0.65625 + px.y * 55)) * exp2(7), vec2(1.0, 0.0), 7);

	return bloom;
}
#endif

void main() {
	#ifdef BLOOM
	bloom = calculateBloomTiles();
	#endif
}
