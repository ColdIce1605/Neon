#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

#define COMPOSITE 1

#include "/cfg/hssrs.scfg"
#include "/cfg/globalIllumination.scfg"

#define REFLECTION_SAMPLES 1 // [0 1 2 4 8 16]

//--// Whatever I end up naming this //------------------------------------------------------------------//

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

/* DRAWBUFFERS:4 */

layout (location = 0) out vec3 composite;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;

in worldStruct world;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform float shadowAngle;

uniform vec3 skyColor;

uniform vec3 shadowLightPosition;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;
uniform mat4 shadowProjection, shadowModelView;
uniform mat4 shadowProjectionInverse;

uniform sampler2D colortex0, colortex1;
uniform sampler2D depthtex1;

uniform sampler2D shadowtex0;
uniform sampler2DShadow shadowtex1;

uniform sampler2D colortex4;
#ifdef GI
uniform sampler2D colortex5;
#endif

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/debug.glsl"

#include "/lib/preprocess.glsl"
#include "/lib/lightingConstants.glsl"
#include "/lib/time.glsl"

#include "/lib/util/packing/normal.glsl"
#include "/lib/util/noise.glsl"
#include "/lib/util/sumof.glsl"

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
vec3 viewSpaceToScreenSpace(vec3 viewSpace) {
	vec4 screenSpace = gbufferProjection * vec4(viewSpace, 1.0);
	return (screenSpace.xyz / screenSpace.w) * 0.5 + 0.5;
}
vec3 viewSpaceToLocalSpace(vec3 viewSpace) {
	return (gbufferModelViewInverse * vec4(viewSpace, 1.0)).xyz;
}

//--//

#include "/lib/light/global.fsh"
#include "/lib/light/sky.fsh"
#include "/lib/light/block.fsh"

//--//

void main() {
	surfaceStruct surface;

	surface.depth.x = texture(depthtex1, fragCoord).r;
	if (surface.depth.x == 1.0) {
		composite = texture(colortex4, fragCoord).rgb;
		debugExit(); return;
	}

	surface.positionScreen = vec3(fragCoord, surface.depth.x);
	surface.positionView   = screenSpaceToViewSpace(surface.positionScreen);
	surface.positionLocal  = viewSpaceToLocalSpace(surface.positionView);

	surface.mat = getPackedMaterial(colortex0, fragCoord);

	surface.normal     = getNormal(fragCoord);
	surface.normalGeom = normalize(cross(dFdx(surface.positionView), dFdy(surface.positionView)));

	//--//

	vec4 tex1BUnpack = unpackUnorm4x8(floatBitsToUint(textureRaw(colortex1, fragCoord).b));

	//--//

	lightStruct light;

	light.engine = tex1BUnpack.rg * tex1BUnpack.rg;

	light.global = calculateGlobalLight(world, surface, tex1BUnpack.b);
	light.sky   = calculateSkyLight(surface.normal, world.upVector, light.engine.y);
	light.block = calculateBlockLight(light.engine.x);

	composite = light.global + light.sky + light.block;

	#if REFLECTION_SAMPLES > 0
	composite *= surface.mat.diffuse;
	#else
	composite *= mix(surface.mat.diffuse, vec3(1.0), surface.mat.specular);
	#endif
	#ifdef MC_GL_VENDOR_NVIDIA
	if (any(isinf(composite) || isnan(composite))) composite = vec3(0.0);
	#endif
	

	debugExit();
}
