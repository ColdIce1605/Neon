#version 420

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:0 */

layout (location = 0) out vec4 packedMaterial;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec4 color;

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
	packedMaterial.r = uintBitsToFloat(packUnorm4x8(color));
	packedMaterial.g = uintBitsToFloat(0xff000000);
	packedMaterial.b = uintBitsToFloat(0xff000000);
	packedMaterial.a = 1.0;
}
