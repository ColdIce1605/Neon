#ifdef fsh

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec4 color;

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
	packedMaterial.r = uintBitsToFloat(packUnorm4x8(color));
	packedMaterial.g = uintBitsToFloat(0xff000000);
	packedMaterial.b = uintBitsToFloat(0xff000000);
	packedMaterial.a = 1.0;
}

#endif

#ifdef vsh

//--// Uniforms //---------------------------------------------------------------------------------------//

//uniform mat4 gbufferProjection;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/gbuffers/initPosition.vsh"

void main() {
	gl_Position = gl_ProjectionMatrix * initPosition();

	color = vertexColor;
}

#endif