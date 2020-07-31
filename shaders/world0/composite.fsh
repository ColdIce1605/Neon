#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

#define COMPOSITE 0

#include "/cfg/globalIllumination.scfg"

//--// Misc

const float sunPathRotation = -30.0;
const int noiseTextureResolution = 128;

//--// Shadows

const int   shadowMapResolution = 2048; // [1024 2048 4096 8192 16384]
const float shadowDistance      = 16.0; // [16.0 32.0]

//--// Texture formats
/*
const int colortex0Format = RG32F;   // Material
const int colortex1Format = RGB32F;  // Normals, lightmap
const int colortex2Format = RGBA16F; // Transparent surfaces
const int colortex3Format = RGBA32F; // Water data
const int colortex4Format = RGB32F;  // Current render
const int colortex5Format = RGBA32F;  // Data sent to next pass
const int colortex6Format = RGBA16F;  //Temporal Data

const int colortex7Format = RGB16F; // Sky
*/

const bool shadowHardwareFiltering1 = true;

const bool shadowtex0Mipmap   = true;
const bool shadowtex1Mipmap   = false;
const bool shadowcolor0Mipmap = true;
const bool shadowcolor1Mipmap = true;

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:457 */

layout (location = 0) out vec3 composite;
layout (location = 1) out vec3 gi;
layout (location = 2) out vec3 sky;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;

in vec3 viewDir;
in vec3 sunDir, moonDir;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform float eyeAltitude;

#ifdef GI
uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex1;

uniform mat4 shadowProjection, shadowModelView;
uniform mat4 shadowProjectionInverse;

uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;
#endif

uniform sampler2D colortex4;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/debug.glsl"

#include "/lib/preprocess.glsl"
#include "/lib/lightingConstants.glsl"

#include "/lib/util/maxof.glsl"
#include "/lib/util/noise.glsl"

//--//

#ifdef GI
vec3 screenSpaceToViewSpace(vec3 screenSpace) {
	vec4 viewSpace = gbufferProjectionInverse * vec4(screenSpace * 2.0 - 1.0, 1.0);
	return viewSpace.xyz / viewSpace.w;
}
vec3 viewSpaceToLocalSpace(vec3 viewSpace) {
	return (gbufferModelViewInverse * vec4(viewSpace, 1.0)).xyz;
}
vec3 projectShadowSpace(vec3 pos) {
	pos = (shadowProjection * vec4(pos, 1.0)).xyz;
	return pos / vec3(vec2(1.0 + length(pos.xy)), 4.0);
}
vec2 projectShadowSpace(vec2 pos) {
	pos = mat2(shadowProjection) * pos;
	return pos / (1.0 + length(pos));
}

#include "/lib/util/packing/normal.glsl"
#include "/lib/composite/get/normal.fsh"

//--//

// I've added these defines for slightly improved clarity.
// I've hard-coded the (inverse) projection into GI_GetDepth. It is technically faster, tough the difference is really negligible.
#define GI_GetDepth(coord)  (textureLod(shadowtex0,   coord, GI_LOD_DEPTH).r * -1023.8 + 383.9)
#define GI_GetNormal(coord) (textureLod(shadowcolor1, coord, GI_LOD_NORMAL).rgb * 2.0 - 1.0)
#define GI_GetAlbedo(coord) (textureLod(shadowcolor0, coord, GI_LOD_ALBEDO).rgb)

vec3 calculateGI(vec3 positionLocal, vec3 normal, bool translucent) {
	const float stp = 0.5 * (GI_RADIUS / (sqrt(GI_SAMPLES) - 1.0));
	vec2 noise = noise2(fragCoord) * stp - (0.5 * stp); // Using noise is slower, but also results in much better quality with fewer samples.

	// Get base shadow-space position and normal.
	vec3 shadowPos    = (shadowModelView * vec4(positionLocal, 1.0)).xyz;
	vec3 shadowNormal = mat3(shadowModelView) * mat3(gbufferModelViewInverse) * normal;

	vec3 result = vec3(0.0);

	// Start the loops.
	// Apparently it's just a tad faster to add noise to the start & end points of the loops.
	for (float x = -GI_RADIUS + noise.x; x < GI_RADIUS + noise.x; x += stp) {
		for (float y = -GI_RADIUS + noise.y; y <= GI_RADIUS + noise.y; y += stp) {
			vec2 offset = vec2(x, y);

			// The first of these gives a HUGE performance boost, at no cost to quality.
			// Second also helps a bit, since it discards anything that's too far away on the XY plane.
			if (dot(shadowNormal.xy, offset) <= 0.0 || dot(offset, offset) > GI_RADIUS * GI_RADIUS) continue;

			// Figure out where this sample is placed in shadow view space.
			vec3 samplePos   = vec3(shadowPos.xy + offset, 0.0);
			vec2 sampleCoord = projectShadowSpace(samplePos.xy) * 0.5 + 0.5;
			     samplePos.z = GI_GetDepth(sampleCoord);

			// Diffs.
			vec3 diffp = samplePos - shadowPos;
			float diffd2 = dot(diffp, diffp);

			// Decent performance boost from this. Discards any sample that's too far away along Z.
			if (diffd2 > GI_RADIUS * GI_RADIUS) continue;

			// Get the normal at this offset.
			vec3 sampleNormal = GI_GetNormal(sampleCoord);

			// Angle-based multiplier.
			vec3 ams = max(vec3(inversesqrt(diffd2) * diffp * mat2x3(shadowNormal, -sampleNormal), sampleNormal.z), 0.0);
			float am = mix(ams.x * ams.y, 1.0, translucent) * ams.z;

			// Decent performance boost as it discards any samples that have normals pointing away from each other.
			if (am <= 0.0) continue;

			// Add to the result the found albedo scaled based on angle and distance.
			result += GI_GetAlbedo(sampleCoord) * am / (diffd2 + 1.0);
		}
	}

	return result * ((GI_RADIUS / GI_SAMPLES) / PI);
}
#endif

//--//

vec3 unprojectSky(vec2 p) {
	p  = p * 2.0 - 1.0;
	p *= maxof(abs(normalize(p)));

	vec4 u = vec4(p, 1.0, -1.0);
	u.z    = dot(u.xyz, -u.xyw);
	u.xy  *= sqrt(u.z);
	return u.xyz * 2.0 + vec3(0.0, -1.0, 0.0);
}

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

// Ray-sphere intersection
vec2 rsi(vec3 pos, vec3 dir, float radSq) {
	float rDot  = dot(pos, dir);
	float delta = sqrt((rDot * rDot) - dot(pos, pos) + radSq);
	return -rDot + vec2(delta, -delta);
}
bool rsib(vec3 pos, vec3 dir, float radSq) {
	float rDot  = dot(pos, dir);
	float delta = (rDot * rDot) - dot(pos, pos) + radSq;
	return delta >= 0.0 && (rDot <= 0.0 || dot(pos, pos) <= radSq);
}

vec3 skyAtmosphere(vec3 viewDir) {
	//--// Constants

	const uint iSteps = 16;
	const uint jSteps = 4; // 2 is pretty much the minimum that's somewhat accurate

	const vec3 sunLightCol  = vec3(ILLUMINANCE_SUN);
	const vec3 moonLightCol = vec3(ILLUMINANCE_MOON);

	const float planetRadius = 6371e3;
	const float atmosRadius  = planetRadius + 100e3;
	const vec2 scaleHeightsRcp = 1.0 / vec2(8e3, 1.2e3);
	const vec2 radiiSqrd = vec2(planetRadius * planetRadius, atmosRadius * atmosRadius);
	const mat2x3 coeffMatrix = mat2x3(vec3(5.8e-6, 1.35e-5, 3.31e-5), vec3(6e-6));

	//--//

	if (viewDir.y < -0.2) return vec3(0.0);

	vec3 pos = vec3(0.0, planetRadius + eyeAltitude, 0.0);

	float iStep = rsi(pos, viewDir, radiiSqrd.y).x / iSteps;
	vec3  iIncr = viewDir * iStep;
	vec3  iPos  = iIncr * -0.5 + pos;

	float sunVoL    = dot(viewDir, sunDir);
	float moonVoL   = dot(viewDir, moonDir);
	vec2  sunPhase  = vec2(rayleighPhase(sunVoL), miePhase(sunVoL));
	vec2  moonPhase = vec2(rayleighPhase(moonVoL), miePhase(moonVoL));

	vec2 odI         = vec2(0.0);
	vec3 sunScatter  = vec3(0.0);
	vec3 moonScatter = vec3(0.0);
	for (uint i = 0; i < iSteps; i++) {
		iPos += iIncr;

		vec2 odIStep = exp(-(length(iPos) - planetRadius) * scaleHeightsRcp) * iStep;

		odI += odIStep;

		// Sun
		{
			float jStep = rsi(iPos, sunDir, radiiSqrd.y).x / jSteps;
			vec3  jIncr = sunDir * jStep;
			vec3  jPos  = jIncr * -0.5 + iPos;

			vec2 odJ = vec2(0.0);
			for (float j = 0.0; j < jSteps; j++) {
				jPos += jIncr;
				odJ  += exp(-(length(jPos) - planetRadius) * scaleHeightsRcp) * jStep;
			}

			sunScatter += (coeffMatrix * (odIStep * sunPhase)) * exp(coeffMatrix * -(odI + odJ));
		}

		// Moon
		{
			float jStep = rsi(iPos, moonDir, radiiSqrd.y).x / jSteps;
			vec3  jIncr = moonDir * jStep;
			vec3  jPos  = jIncr * -0.5 + iPos;

			vec2 odJ = vec2(0.0);
			for (float j = 0.0; j < jSteps; j++) {
				jPos += jIncr;
				odJ  += exp(-(length(jPos) - planetRadius) * scaleHeightsRcp) * jStep;
			}

			moonScatter += (coeffMatrix * (odIStep * moonPhase)) * exp(coeffMatrix * -(odI + odJ));
		}
	}

	if (any(isnan(sunScatter))) sunScatter = vec3(0.0);
	if (any(isnan(moonScatter))) moonScatter = vec3(0.0);

	return (sunScatter * sunLightCol) + (moonScatter * moonLightCol);
}

void skyAtmosphere(vec3 viewDir, out vec3 inscattered, out vec3 transmittance) {
	//--// Constants

	const uint iSteps = 20;
	const uint jSteps = 4; // 2 is pretty much the minimum that's somewhat accurate

	const vec3 sunLightCol  = vec3(ILLUMINANCE_SUN);
	const vec3 moonLightCol = vec3(ILLUMINANCE_MOON);

	const float planetRadius = 6371e3;
	const float atmosRadius  = planetRadius + 100e3;
	const vec2 scaleHeightsRcp = 1.0 / vec2(8e3, 1.2e3);
	const vec2 radiiSqrd = vec2(planetRadius * planetRadius, atmosRadius * atmosRadius);
	const mat2x3 coeffMatrix = mat2x3(vec3(5.8e-6, 1.35e-5, 3.31e-5), vec3(6e-6));

	//--//

	if (viewDir.y < -0.2) {
		inscattered = vec3(0.0); transmittance = vec3(0.0);
		return;
	}

	vec3 pos = vec3(0.0, planetRadius + eyeAltitude, 0.0);

	float iStep = rsi(pos, viewDir, radiiSqrd.y).x / iSteps;
	vec3  iIncr = viewDir * iStep;
	vec3  iPos  = iIncr * -0.5 + pos;

	float sunVoL    = dot(viewDir, sunDir);
	float moonVoL   = dot(viewDir, moonDir);
	vec2  sunPhase  = vec2(rayleighPhase(sunVoL), miePhase(sunVoL));
	vec2  moonPhase = vec2(rayleighPhase(moonVoL), miePhase(moonVoL));

	vec2 odI         = vec2(0.0);
	vec3 sunScatter  = vec3(0.0);
	vec3 moonScatter = vec3(0.0);
	for (uint i = 0; i < iSteps; i++) {
		iPos += iIncr;

		vec2 odIStep = exp(-(length(iPos) - planetRadius) * scaleHeightsRcp) * iStep;

		odI += odIStep;

		// Sun
		{
			float jStep = rsi(iPos, sunDir, radiiSqrd.y).x / jSteps;
			vec3  jIncr = sunDir * jStep;
			vec3  jPos  = jIncr * -0.5 + iPos;

			vec2 odJ = vec2(0.0);
			for (float j = 0.0; j < jSteps; j++) {
				jPos += jIncr;
				odJ  += exp(-(length(jPos) - planetRadius) * scaleHeightsRcp) * jStep;
			}

			sunScatter += (coeffMatrix * (odIStep * sunPhase)) * exp(coeffMatrix * -(odI + odJ));
		}

		// Moon
		{
			float jStep = rsi(iPos, moonDir, radiiSqrd.y).x / jSteps;
			vec3  jIncr = moonDir * jStep;
			vec3  jPos  = jIncr * -0.5 + iPos;

			vec2 odJ = vec2(0.0);
			for (float j = 0.0; j < jSteps; j++) {
				jPos += jIncr;
				odJ  += exp(-(length(jPos) - planetRadius) * scaleHeightsRcp) * jStep;
			}

			moonScatter += (coeffMatrix * (odIStep * moonPhase)) * exp(coeffMatrix * -(odI + odJ));
		}
	}

	if (any(isnan(sunScatter))) sunScatter = vec3(0.0);
	if (any(isnan(moonScatter))) moonScatter = vec3(0.0);

	inscattered = (sunScatter * sunLightCol) + (moonScatter * moonLightCol);
	transmittance = exp(coeffMatrix * -odI);
}

//--//

void main() {
	#ifdef GI
	vec2 gifc = fragCoord * (1.0 / GI_RESOLUTION);
	if (all(lessThan(gifc, vec2(1.0)))) {
		int id = int(unpackUnorm4x8(floatBitsToUint(texelFetch(colortex0, ivec2(gifc * textureSize(colortex0, 0)), 0).r)).a * 255.0);

		bool translucent =
		   id ==  18 // Leaves
		|| id ==  30 // Cobweb
		|| id ==  31 // Tall grass and fern
		|| id ==  37 // Flowers
		|| id ==  59 // Crops
		|| id ==  83 // Sugar canes
		|| id == 106 // Vines
		|| id == 111 // Lily pad
		|| id == 175 // Double plants
		;

		gi = calculateGI(viewSpaceToLocalSpace(screenSpaceToViewSpace(vec3(gifc, texture(depthtex1, gifc).r))), getNormal(gifc), translucent);
	}
	else
	#endif
	//gi = vec3(0.0);

	composite = texture(colortex4, fragCoord).rgb; // Stars, sun, moon
	{ // Atmosphere
		vec3 inscattered, transmittance;
		skyAtmosphere(normalize(viewDir), inscattered, transmittance);
		composite = composite * transmittance + inscattered;
	}

	sky = skyAtmosphere(unprojectSky(fragCoord));

	debugExit();
}
