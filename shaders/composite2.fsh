#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

#define COMPOSITE 2

#include "/cfg/fog.scfg"

#define REFLECTION_SAMPLES 1 // [0 1 2 4 8 16 32]
#define REFLECTION_BOUNCES 1 // [1 2 4]

//--// Materials //--------------------------------------------------------------------------------------//

#include "/lib/materials.glsl"

//--// Structs //----------------------------------------------------------------------------------------//

struct surfaceStruct {
	material mat;

	vec3 normal;
	vec3 normalGeom;

	float depth;

	vec3 positionScreen; // Position in screen-space
	vec3 positionView;   // Position in view-space
	vec3 positionLocal;  // Position in local-space
};

struct worldStruct {
	vec3 globalLightVector;
	vec3 globalLightColor;
};

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:4 */

layout (location = 0) out vec3 composite;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;

in worldStruct world;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform int isEyeInWater;

uniform float eyeAltitude;
uniform ivec2 eyeBrightness;

uniform float sunAngle;

uniform vec3 skyColor;

uniform vec3 shadowLightPosition;
uniform vec3 sunPosition;
uniform vec3 upPosition;

uniform mat4 gbufferProjection, gbufferModelView;
uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;
uniform mat4 shadowProjection, shadowModelView;

uniform sampler2D colortex0, colortex1;
uniform sampler2D colortex2; // Transparent surfaces
uniform sampler2D colortex3; // Water
uniform sampler2D colortex4; // Previous pass
uniform sampler2D colortex7; // Sky

uniform sampler2D depthtex0, depthtex1;

uniform sampler2DShadow shadowtex1;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/debug.glsl"

#include "/lib/preprocess.glsl"
#include "/lib/lightingConstants.glsl"

#include "/lib/util/packing/normal.glsl"
#include "/lib/util/maxof.glsl"
#include "/lib/util/noise.glsl"

//--//

#include "/lib/composite/get/normal.fsh"

//--//

float linearizeDepth(float depth) {
	return -1.0 / ((depth * 2.0 - 1.0) * gbufferProjectionInverse[2].w + gbufferProjectionInverse[3].w);
}
vec3 screenSpaceToViewSpace(vec3 screenSpace) {
	vec4 viewSpace = gbufferProjectionInverse * vec4(screenSpace * 2.0 - 1.0, 1.0);
	return viewSpace.xyz / viewSpace.w;
}
vec3 viewSpaceToLocalSpace(vec3 viewSpace) {
	return (gbufferModelViewInverse * vec4(viewSpace, 1.0)).xyz;
}
vec3 viewSpaceToScreenSpace(vec3 viewSpace) {
	vec4 screenSpace = gbufferProjection * vec4(viewSpace, 1.0);
	return (screenSpace.xyz / screenSpace.w) * 0.5 + 0.5;
}

//--//

vec3 skySun(vec3 viewVec, vec3 sunVec) {
	return float(dot(viewVec, sunVec) > cos(radians(4.5))) * LUMINANCE_SUN * vec3(1.0, 0.96, 0.95);
}

vec3 getSky(vec3 dir) {
	vec2 p = dir.xz * inversesqrt(dir.y * 8.0 + 8.0) * 2.0;
	p /= maxof(abs(normalize(p)));

	vec3 sky = texture(colortex7, p * 0.5 + 0.5).rgb;
	sky += skySun(dir, mat3(gbufferModelViewInverse) * sunPosition * 0.01);

	return sky;
}

//--//

vec3 f0ToIOR(vec3 f0) {
	f0 = sqrt(f0);
	return (1.0 + f0) / (1.0 - f0);
}

#include "/lib/reflectanceModels.glsl"

//--//

#include "/lib/composite/raytracer.fsh"

vec3 is(vec3 normal, vec3 noise, float roughness) {
	if (roughness != 0.0) {
		roughness = (1.0 / roughness) * (1.0 - roughness);
		roughness = pow(dot(normal, noise) * -0.5 + 0.5, roughness);
	}
	return normalize(normal + noise * roughness);
}

vec3 calculateReflection(surfaceStruct surface) { 
	float skyVis = unpackUnorm2x16(floatBitsToUint(textureRaw(colortex1, fragCoord).a)).y;

	vec3 reflection = vec3(0.0);
	const uint samples = REFLECTION_SAMPLES;
	const uint bounces = REFLECTION_BOUNCES;
	for (uint i = 0; i < samples; i++) {
		vec3 rayDir = normalize(surface.positionView);

		material hitMaterial = surface.mat;
		vec3 hitNormal = is(surface.normal, normalize(noise3(fragCoord + i) * 2.0 - 1.0), hitMaterial.roughness);

		vec3 reflColor = vec3(1.0);
		vec3 hitCoord  = surface.positionScreen;
		vec3 hitPos    = surface.positionView;

		for (uint j = 0; j < bounces; j++) {
			reflColor *= f_fresnel(max0(dot(hitNormal, -rayDir)), hitMaterial.specular);
			if (reflColor == vec3(0.0)) break;

			rayDir = reflect(rayDir, hitNormal);

			if (raytraceIntersection(hitPos, rayDir, hitCoord, hitPos)) {
				reflection += texture(colortex4, hitCoord.st).rgb * reflColor;
			} else if (skyVis > 0) {
				reflection += getSky(mat3(gbufferModelViewInverse) * rayDir) * skyVis * reflColor;
				break;
			}

			hitMaterial = getPackedMaterial(colortex0, hitCoord.st);
			hitNormal   = is(getNormal(hitCoord.st), normalize(noise3(fragCoord + i) * 2.0 - 1.0), hitMaterial.roughness);
		}
	}

	if (any(isnan(reflection))) reflection = vec3(0.0);

	return reflection / samples;
}

//--//

vec3 waterFog(vec3 col, float dist) {
	const vec3 acoeff = vec3(1.20, 0.65, 0.45);
	const vec3 scoeff = vec3(5.4e-4, 1.5e-3, 3.1e-3);

	vec3 transmittance = exp(-acoeff * dist);
	vec3 scattered = scoeff * (1.0 - exp(-acoeff * dist)) / acoeff;

	return col * transmittance + world.globalLightColor * scattered;
}

vec3 calculateWaterShading(surfaceStruct surface) {
	vec3 tex3Raw = textureRaw(colortex3, fragCoord).rgb;

	vec3 screenPos = vec3(fragCoord, tex3Raw.b);
	vec3 viewPos   = screenSpaceToViewSpace(screenPos);

	vec3 viewDir = normalize(viewPos);

	vec3  normal = unpackNormal(tex3Raw.rg);
	float skyVis = eyeBrightness.y / 240.0; // temp

	vec3 f = saturate(f_fresnel(dot(normal, -viewDir), vec3(0.02)));

	// Reflections
	vec3 reflection = vec3(0.0); {
		vec3 rayDir = reflect(viewDir, normal);

		vec3 hitCoord;
		vec3 hitPos;
		if (raytraceIntersection(viewPos, rayDir, hitCoord, hitPos)) {
			reflection = texture(colortex4, hitCoord.xy).rgb;
		} else if (skyVis > 0 && isEyeInWater == 0) {
			reflection = getSky(mat3(gbufferModelViewInverse) * rayDir) * skyVis;
		}

		if (isEyeInWater == 1) {
			reflection = waterFog(reflection, distance(viewPos, hitPos));

			// Needed because hitPos sometimes gets bad values.
			if (isnan(reflection.r)) reflection = vec3(0.0);
		}
	}

	// Refractions
	vec3 refraction; {
		vec3 rayDir = refract(viewDir, normal, 0.75);

		float refractAmount = saturate(distance(viewPos, surface.positionView));

		vec3 hitPos   = rayDir * refractAmount + viewPos;
		vec3 hitCoord = viewSpaceToScreenSpace(hitPos);
		hitCoord.z = texture(depthtex1, hitCoord.xy).r;
		hitPos.z = linearizeDepth(hitCoord.z);

		if (hitCoord.z == 1.0) {
			refraction = getSky(mat3(gbufferModelViewInverse) * rayDir);
		} else {
			refraction = texture(colortex4, hitCoord.xy).rgb;
		}

		if (isEyeInWater == 0) {
			refraction = waterFog(refraction, distance(viewPos, hitPos));
		}
	}

	vec3 waterShading = mix(refraction, reflection, f);

	if (isEyeInWater == 1) {
		waterShading = waterFog(waterShading, length(viewPos));
	}

	return waterShading;
}

//--//

#ifdef FOG
float miePhase(float cosTheta) {
	const float g  = 0.8;
	const float gg = g * g;

	const float p1 = (3.0 * (1.0 - gg)) / (2.0 * (2.0 + gg));
	float p2 = (cosTheta * cosTheta + 1.0) / pow(1.0 + gg - 2.0 * g * cosTheta, 1.5);

	return p1 * p2;
}
float rayleighPhase(float cosTheta) {
	return 0.75 * (cosTheta * cosTheta + 1.0);
}

#ifdef VL
vec3 localSpaceToShadowSpace(vec3 localPos) {
	vec3 shadowPos = (shadowProjection * shadowModelView * vec4(localPos, 1.0)).xyz;
	return vec3(shadowPos.xy / (1.0 + length(shadowPos.xy)), shadowPos.z / 4.0);
}

void calculateVolumetricLight(vec3 viewVector, float linearDepth, out vec3 transmittance, out vec3 inscatter) {
	float stepSize = (linearDepth / viewVector.z) / VL_STEPS;

	mat2x3 coeffMatrix = mat2x3(vec3(5.8e-6, 1.35e-5, 3.31e-5), vec3(3e-6)) * FOG_MULT;

	float VoL = dot(viewVector, world.globalLightVector);
	coeffMatrix[0] *= rayleighPhase(VoL);
	coeffMatrix[1] *= miePhase(VoL);

	vec3 increment = mat3(gbufferModelViewInverse) * viewVector * stepSize;
	vec3 localPos = -increment * noise1(fragCoord) + gbufferModelViewInverse[3].xyz;

	transmittance = vec3(1.0), inscatter = vec3(0.0);
	for (uint i = 0; i < VL_STEPS; i++) {
		localPos += increment;

		vec2 odStep = exp(-(localPos.y + eyeAltitude) / vec2(8e3, 1.2e3)) * stepSize;
		transmittance *= exp(coeffMatrix * -odStep);

		inscatter += (coeffMatrix * odStep) * transmittance * texture(shadowtex1, localSpaceToShadowSpace(localPos) * 0.5 + 0.5);
	}
}
#endif

vec3 calculateFog(vec3 color, vec3 viewVector, float linearDepth) {
	vec3 transmittance = vec3(1.0), inscatter = vec3(0.0);

	#ifdef VL
	calculateVolumetricLight(viewVector, linearDepth, transmittance, inscatter);
	#else
	const mat2x3 scoeffs = mat2x3(vec3(5.8e-6, 1.35e-5, 3.31e-5), vec3(3e-6)) * FOG_MULT;
	const vec3 acoeff = scoeffs[0] + scoeffs[1];
	const vec3 scoeff = scoeffs[0] + scoeffs[1];
	float dist = linearDepth / viewVector.z;
	float VoL = dot(viewVector, world.globalLightVector);
	transmittance = exp(-acoeff * dist);
	inscatter     = scoeffs[0] * rayleighPhase(VoL) * (1.0 - exp(-acoeff * dist)) / acoeff;
	#endif

	return color * transmittance + inscatter * world.globalLightColor;
}
#endif

//--//

void main() {
	surfaceStruct surface;

	surface.depth.x = texture(depthtex1, fragCoord).r;

	surface.positionScreen = vec3(fragCoord, surface.depth.x);
	surface.positionView   = screenSpaceToViewSpace(surface.positionScreen);
	surface.positionLocal  = viewSpaceToLocalSpace(surface.positionView);

	if (surface.depth.x == 1.0) {
		if (texture(colortex3, fragCoord).a > 0.0) {
			composite = calculateWaterShading(surface);
		} else {
			composite = texture(colortex4, fragCoord).rgb;

			if (isEyeInWater == 1) {
				composite = waterFog(composite, length(surface.positionView));
			}
		}

		vec4 trans = texture(colortex2, fragCoord);
		composite = mix(composite, trans.rgb, trans.a);

		debugExit(); return;
	}

	surface.mat = getPackedMaterial(colortex0, fragCoord);

	surface.normal     = getNormal(fragCoord);
	surface.normalGeom = normalize(cross(dFdx(surface.positionView), dFdy(surface.positionView)));

	composite = texture(colortex4, fragCoord).rgb;

	bool waterMask = texture(colortex3, fragCoord).a > 0.0;

	#if REFLECTION_SAMPLES > 0
	if (any(greaterThan(surface.mat.specular, vec3(0.0))) && !waterMask) {
		composite *= saturate(1.0 - f_fresnel(max(dot(surface.normal, -normalize(surface.positionView)), 0.0), surface.mat.specular)*surface.mat.roughness);
		composite += calculateReflection(surface) * (1.0 - surface.mat.roughness);
	}
	#endif

	composite += surface.mat.emission * LUMINANCE_BLOCK;

	if (waterMask) {
		composite = calculateWaterShading(surface);
	} else if (isEyeInWater == 1) {
		composite = waterFog(composite, length(surface.positionView));
	}

	#ifdef FOG
	composite = calculateFog(composite, normalize(surface.positionView), surface.positionView.z);
	#endif

	if (waterMask) composite /= 0.8; // Water needs some opacity to render, this hides the effects of that.

	vec4 trans = texture(colortex2, fragCoord);
	composite = mix(composite, trans.rgb, trans.a);

	debugExit();
}
