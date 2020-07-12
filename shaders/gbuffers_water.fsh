#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

//--// Whatever I end up naming this //------------------------------------------------------------------//

#include "/lib/materials.glsl"

//--// Structs //----------------------------------------------------------------------------------------//

struct surfaceStruct {
	material mat;

	vec3 normal;
	vec3 normalGeom;

	vec2 depth; // y is linearized

	vec3 positionScreen; // Position in screen-space
	vec3 positionView;   // Position in view-space
	vec3 positionLocal;  // Position in local-space
};

struct lightStruct {
	vec2 engine;

	vec3 global;
	vec3 sky;
	vec3 block;
};

struct worldStruct {
	vec3 globalLightVector;
	vec3 globalLightColor;

	vec3 upVector;
};

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:23 */

layout (location = 0) out vec4 data0;
layout (location = 1) out vec4 data1;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec3 positionView, positionLocal;

in mat3 tbnMatrix;
in vec4 tint;
in vec2 baseUV, lmUV;
in float blockID;

in worldStruct world;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform float shadowAngle;

uniform vec3 skyColor;

uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

uniform mat4 shadowModelView, shadowProjection;
uniform mat4 shadowProjectionInverse;

uniform sampler2D base, specular;
uniform sampler2D normals;

uniform sampler2D shadowtex0;
uniform sampler2DShadow shadowtex1;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/preprocess.glsl"
#include "/lib/lightingConstants.glsl"
#include "/lib/time.glsl"

#include "/lib/util/packing/normal.glsl"
#include "/lib/util/noise.glsl"
#include "/lib/util/sumof.glsl"

//--//

vec3 getNormal(vec2 coord) {
	vec3 tsn = texture(normals, coord).rgb;
	tsn.xy += 0.5 / 255.0; // Need to add this for correct results.
	return tbnMatrix * normalize(tsn * 2.0 - 1.0);
}

//--//

float sharpenWave(float wave, float sharpness, float amount) {
	float m = 1.0 - sharpness;

	float swave = abs(wave * 2.0 - 1.0);
	if (swave < 2.0 * m) swave = ((0.25 / m) * swave * swave) + m;
	return mix(wave, swave, amount);
}
float smoothNoise(vec2 coord) {
	vec2 fl = floor(coord);
	vec4 ns = vec4(
		noise1(fl + vec2(-0.5,-0.5)), noise1(fl + vec2( 0.5,-0.5)),
		noise1(fl + vec2(-0.5, 0.5)), noise1(fl + vec2( 0.5, 0.5))
	);

	vec2 fr = fract(coord); fr *= fr * (3.0 - 2.0 * fr);

	fl = mix(ns.xz, ns.yw, fr.x);
	return mix(fl.x, fl.y, fr.y);
}
float calculateWaterWaves(vec2 pos) {
	//--//

	const vec4 aspect = vec4( 1.42, 2.42, 0.83, 1.25);
	const vec4 height = vec4( 0.01, 0.03, 0.06, 0.10);
	const vec4 length = vec4( 0.63, 1.26, 1.65, 3.23);
	const vec4 rotate = vec4(-0.10, 0.30, 0.50, 0.50);
	const vec4 skewx  = vec4( 0.10, 0.40, 1.50, 1.50);
	const vec4 skewy  = vec4(-1.20, 1.10, 1.50, 1.70);
	const vec4 sharpn = vec4( 0.00, 0.20, 0.00, 0.60);

	const vec4 k = TAU / length;
	const vec4 omega = sqrt(32.0 / k) / TAU;

	//--//

	const mat2 r0 = mat2(cos(rotate.x), sin(rotate.x) / aspect.x, -sin(rotate.x), cos(rotate.x) / aspect.x) * k.x / TAU;
	const mat2 r1 = mat2(cos(rotate.y), sin(rotate.y) / aspect.y, -sin(rotate.y), cos(rotate.y) / aspect.y) * k.y / TAU;
	const mat2 r2 = mat2(cos(rotate.z), sin(rotate.z) / aspect.z, -sin(rotate.z), cos(rotate.z) / aspect.z) * k.z / TAU;
	const mat2 r3 = mat2(cos(rotate.w), sin(rotate.w) / aspect.w, -sin(rotate.w), cos(rotate.w) / aspect.w) * k.w / TAU;

	vec2 p0 = (r0 * pos) - vec2(omega.x * globalTime, 0.0); p0 += p0.yx * vec2(skewx.x, skewy.x);
	vec2 p1 = (r1 * pos) - vec2(omega.y * globalTime, 0.0); p1 += p1.yx * vec2(skewx.y, skewy.y);
	vec2 p2 = (r2 * pos) - vec2(omega.z * globalTime, 0.0); p2 += p2.yx * vec2(skewx.z, skewy.z);
	vec2 p3 = (r3 * pos) - vec2(omega.w * globalTime, 0.0); p3 += p3.yx * vec2(skewx.w, skewy.w);

	float wave = 0.0;

	wave -= height.x * sharpenWave(smoothNoise(p0), 0.1, sharpn.x);
	wave -= height.y * sharpenWave(smoothNoise(p1), 0.1, sharpn.y);
	wave -= height.z * sharpenWave(smoothNoise(p2), 0.1, sharpn.z);
	wave -= height.w * sharpenWave(smoothNoise(p3), 0.1, sharpn.w);

	return wave;
}
vec3 calculateWaterParallax(vec3 pos, vec3 dir) {
	const int steps = 8;

	vec3  increm = vec3(2.0 / steps) * (dir / abs(dir.z));
	vec3  offset = vec3(0.0, 0.0, 0.0);
	float height = calculateWaterWaves(pos.xy);

	for (int i = 0; i < steps && height < offset.z; i++) {
		offset += mix(vec3(0.0), increm, pow(offset.z - height, 0.8));
		height  = calculateWaterWaves(pos.xy + offset.xy);
	}

	return pos + vec3(offset.xy, 0.0);
}
vec3 calculateWaterNormal(vec3 pos, vec3 viewDir) {
	pos = calculateWaterParallax(pos.xzy, viewDir);

	vec2 diff = vec2(calculateWaterWaves(pos.xy + vec2(0.1,-0.1)),
	                 calculateWaterWaves(pos.xy - vec2(0.1,-0.1)));
	     diff = (calculateWaterWaves(pos.xy - 0.1) - diff) * 5.0;

	vec3 normal = tbnMatrix * vec3(diff, sqrt(1.0 - saturate(dot(diff, diff))));
	     normal = mix(tbnMatrix[2], normal, pow(saturate(dot(normalize(-positionView), normal)), 0.2));

	return normal;
}

//--//

#include "/lib/light/global.fsh"
#include "/lib/light/sky.fsh"
#include "/lib/light/block.fsh"

//--//

void main() {
	if (abs(blockID - 8.5) < 0.6) {
		vec3 viewDir = normalize(positionView) * tbnMatrix;
		data0 = vec4(0.0, 0.0, 0.0, 0.2);
		data1.rg = packNormal(calculateWaterNormal(positionLocal + cameraPosition, viewDir));
		data1.b = gl_FragCoord.z;
		data1.a = 1.0;

		return;
	}

	data1 = vec4(0.0);

	data0 = texture(base, baseUV) * tint;
	if (data0.a == 0.0) discard;

	data0.rgb = pow(data0.rgb, vec3(GAMMA));

	surfaceStruct surface;
	surface.mat = getMaterial(base, specular, baseUV);

	surface.positionView  = positionView;
	surface.positionLocal = positionLocal;

	surface.normal     = getNormal(baseUV);
	surface.normalGeom = tbnMatrix[2];

	lightStruct light;
	light.engine = lmUV;

	light.global = calculateGlobalLight(world, surface);
	light.sky    = calculateSkyLight(surface.normal, world.upVector, light.engine.y);
	light.block  = calculateBlockLight(light.engine.x);

	data0.rgb *= light.global + light.sky;
}
