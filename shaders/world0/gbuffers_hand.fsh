#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"
#include "/cfg/debug.scfg"


//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:01 */

layout (location = 0) out vec4 packedMaterial;
layout (location = 1) out vec4 packedData;

//--// Inputs //-----------------------------------------------------------------------------------------//

in mat3 tbnMatrix;
in vec4 tint;
in vec2 baseUV, lmUV;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform sampler2D base, specular;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/util/packing/normal.glsl"

void main() {
	vec4 baseTex = texture(base, baseUV) * tint;
	if (baseTex.a < 0.102) discard; // ~ 26 / 255
	vec4 diff = vec4(baseTex.rgb, 254.0 / 255.0);
	vec4 spec = texture(specular, baseUV);
	vec4 emis = vec4(0.0);

	//--//

	packedMaterial = vec4(uintBitsToFloat(uvec3(packUnorm4x8(diff), packUnorm4x8(spec), packUnorm4x8(emis))), 1.0);
	#ifdef ONLY_COLOR
	packedMaterial = vec4(uintBitsToFloat(uvec3(packUnorm4x8(diff), packUnorm4x8(vec4(0.0)), packUnorm4x8(emis))), 1.0);
	#endif
	#ifdef DEBUG_NORMAL
	packedMaterial = vec4(uintBitsToFloat(uvec3(packUnorm4x8(packNormal(tbnMatrix[2]).xyyy), packUnorm4x8(vec4(0.0)), packUnorm4x8(emis))), 1.0);
	#endif
	#ifdef DEBUG_SPEC
	packedMaterial = vec4(uintBitsToFloat(uvec3(packUnorm4x8(spec), packUnorm4x8(vec4(0.0)), packUnorm4x8(emis))), 1.0);
	#endif

	packedData.rg = packNormal(tbnMatrix[2]);
	packedData.b = uintBitsToFloat(packUnorm4x8(vec4(sqrt(lmUV), 1.0, 0.0)));
	packedData.a = baseTex.a;
}
