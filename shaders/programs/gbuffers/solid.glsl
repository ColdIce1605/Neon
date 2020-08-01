#ifdef fsh

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec3 positionView;

in mat3 tbnMatrix;
in vec4 tint;
in vec2 baseUV, lmUV;
in vec4 metadata;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform vec3 shadowLightPosition;

uniform mat4 gbufferProjection;

uniform sampler2D base, specular;
uniform sampler2D normals;

//--// Global constants & variables //-------------------------------------------------------------------//

#ifdef POM
float lodLevel = textureQueryLod(base, baseUV).x;
#define texture(x, y) textureLod(x, y, lodLevel)
#endif

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/preprocess.glsl"

//--//

#ifdef POM_DEPTH_WRITE
float delinearizeDepth(float depth) {
	return ((depth * gbufferProjection[2].z + gbufferProjection[3].z) / (depth * gbufferProjection[2].w + gbufferProjection[3].w)) * 0.5 + 0.5;
}
#endif

vec3 calculateParallaxCoord(vec2 coord, vec3 dir) {
	#ifdef POM
		#ifdef POM_DEPTH_WRITE
		gl_FragDepth = gl_FragCoord.z;
		#endif

	vec2 atlasTiles = textureSize(base, 0) / TEXTURE_RESOLUTION;
	vec4 tcoord = vec4(fract(coord * atlasTiles), floor(coord * atlasTiles));

	vec3 increment = (2.0 / POM_STEPS) * vec3(POM_DEPTH, POM_DEPTH, 1.0) * (dir / -dir.z);
	float foundHeight = texture(normals, coord).a;
	vec3 offset = vec3(0.0, 0.0, 1.0);

	for (int i = 0; i < POM_STEPS && foundHeight < offset.z; i++) {
		offset += increment * pow(offset.z - foundHeight, 0.8);
		foundHeight = texture(normals, (fract(tcoord.xy + offset.xy) + tcoord.zw) / atlasTiles).a;
	}

	#ifdef POM_DEPTH_WRITE
	gl_FragDepth = delinearizeDepth(positionView.z + (normalize(positionView).z * length(vec3(offset.xy, offset.z * POM_DEPTH - POM_DEPTH))));
	#endif

	return vec3((fract(tcoord.xy + offset.xy) + tcoord.zw) / atlasTiles, offset.z);
	#else
	return vec3(coord, 1.0);
	#endif
}

float calculateParallaxSelfShadow(vec3 coord, vec3 dir) {
	#ifdef PSS
	if (dot(tbnMatrix[2], shadowLightPosition) <= 0.0) return 0.0;

	const vec2 atlasTiles = textureSize(base, 0) / TEXTURE_RESOLUTION;

	vec4 tcoord = vec4(fract(coord.xy * atlasTiles), floor(coord.xy * atlasTiles));

	vec3 increment = vec3(POM_DEPTH, POM_DEPTH, 1.0) * (dir / dir.z) / PSS_STEPS;
	vec3 offset = vec3(0.0, 0.0, coord.z);

	for (int i = 0; i < PSS_STEPS && offset.z < 1.0; i++) {
		offset += increment;

		float foundHeight = texture(normals, (fract(tcoord.xy + offset.xy) + tcoord.zw) / atlasTiles).a;
		if (offset.z < foundHeight) return 0.0;
	}
	#endif

	return 1.0;
}

vec3 getNormal(vec2 coord) {
	vec3 tsn = texture(normals, coord).rgb;
	tsn.xy += 0.5 / 255.0; // Need to add this for correct results.
	return tbnMatrix * normalize(tsn * 2.0 - 1.0);
}

#include "/lib/util/packing/normal.glsl"

void main() {
	vec3 pCoord = calculateParallaxCoord(baseUV, normalize(positionView) * tbnMatrix);

	vec4 baseTex = texture(base, pCoord.st) * tint;
	if (baseTex.a < 0.102) discard; // ~ 26 / 255
	
	vec4 diff = vec4(baseTex.rgb, metadata.x / 255.0);
	
	#ifdef WHITEWORLD
	diff = vec4(1.0);
	#endif
	
	vec4 spec = texture(specular, pCoord.st);
	vec4 emis = vec4(0.0, spec.a, 0.0, 1.0);

	//--//

	packedMaterial = vec4(uintBitsToFloat(uvec3(packUnorm4x8(diff), packUnorm4x8(spec), packUnorm4x8(emis))), 1.0);
	#ifdef ONLY_COLOR
	packedMaterial = vec4(uintBitsToFloat(uvec3(packUnorm4x8(diff), packUnorm4x8(vec4(0.0)), packUnorm4x8(vec4(0.0)))), 1.0);
	#endif
	#ifdef DEBUG_NORMAL
	packedMaterial = vec4(uintBitsToFloat(uvec3(packUnorm4x8(getNormal(pCoord.st).xyzz), packUnorm4x8(vec4(0.0)), packUnorm4x8(vec4(0.0)))), 1.0);
	#endif
	#ifdef DEBUG_SPEC
	packedMaterial = vec4(uintBitsToFloat(uvec3(packUnorm4x8(spec), packUnorm4x8(vec4(0.0)), packUnorm4x8(vec4(0.0)))), 1.0);
	#endif
	#ifdef DEBUG_EMIS
	packedMaterial = vec4(uintBitsToFloat(uvec3(packUnorm4x8(emis), packUnorm4x8(vec4(0.0)), packUnorm4x8(vec4(0.0)))), 1.0);
	#endif

	packedData.rg = packNormal(getNormal(pCoord.st));
	packedData.b = uintBitsToFloat(packUnorm4x8(vec4(sqrt(lmUV), calculateParallaxSelfShadow(pCoord, normalize(shadowLightPosition * tbnMatrix)), 0.0)));
	packedData.a = 1.0;
}
#endif

#ifdef vsh

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform float rainStrength;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView, gbufferProjection;
uniform mat4 gbufferModelViewInverse;

uniform sampler2D noisetex;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/preprocess.glsl"
#include "/lib/time.glsl"

#include "/lib/util/textureBicubic.glsl"
#include "/lib/util/textureSmooth.glsl"

//--//

#include "/lib/gbuffers/initPosition.vsh"

mat3 calculateTBN() {
	vec3 tangent = normalize(vertexTangent.xyz);

	return mat3(
		gl_NormalMatrix * tangent,
		gl_NormalMatrix * cross(tangent, vertexNormal) * sign(vertexTangent.w),
		gl_NormalMatrix * vertexNormal
	);
}

//--//

#include "/lib/gbuffers/displacement.vsh"

//--//

void main() {
	gl_Position = initPosition();
	positionView = gl_Position.xyz;
	vec4 positionLocal = gbufferModelViewInverse * gl_Position;
	vec4 positionWorld = positionLocal + vec4(cameraPosition, 0.0);
	calculateDisplacement(positionWorld.xyz);
	positionLocal = positionWorld - vec4(cameraPosition, 0.0);
	gl_Position = gbufferModelView * positionLocal;
	gl_Position = gbufferProjection * gl_Position;

	tbnMatrix = calculateTBN();
	tint      = vertexColor;
	baseUV    = vertexUV;
	lmUV      = vertexLightmap / 240.0;
	metadata  = vertexMetadata;
}

#endif