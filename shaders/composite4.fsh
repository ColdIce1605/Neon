#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

#define COMPOSITE 4

#include "/cfg/bloom.scfg"

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:5 */

layout (location = 0) out vec4 bloom;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;

//--// Uniforms //---------------------------------------------------------------------------------------//

#ifdef BLOOM
uniform float viewHeight;
uniform sampler2D colortex5;
#endif

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
	// TODO: Limit it to the tiles.

	#ifdef BLOOM
	const float[5] weights = float[5](0.19947114, 0.29701803, 0.09175428, 0.01098007, 0.00050326);
	const float[5] offsets = float[5](0.00000000, 1.40733340, 3.29421497, 5.20181322, 7.13296424);

	bloom = texture(colortex5, fragCoord) * weights[0];
	for (int i = 1; i < 5; i++) {
		vec2 offset = offsets[i] * vec2(0.0, 1.0 / viewHeight);
		bloom += texture(colortex5, fragCoord + offset) * weights[i];
		bloom += texture(colortex5, fragCoord - offset) * weights[i];
	}
	#endif
}
