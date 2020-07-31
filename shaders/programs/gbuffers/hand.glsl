#ifdef fsh

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

#endif

#ifdef vsh

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform mat4 gbufferProjection;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/gbuffers/initPosition.vsh"

mat3 calculateTBN() {
	vec3 tangent = normalize(vertexTangent.xyz);

	return mat3(
		gl_NormalMatrix * tangent,
		gl_NormalMatrix * cross(tangent, vertexNormal) * sign(vertexTangent.w),
		gl_NormalMatrix * vertexNormal
	);
}

void main() {
	gl_Position = gbufferProjection * initPosition();

	tbnMatrix = calculateTBN();
	tint      = vertexColor;
	baseUV    = vertexUV;
	lmUV      = vertexLightmap / 240.0;
}

#endif