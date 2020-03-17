#version 420 compatibility
#define gbuffers_skybasic
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

// Sky options
#define RAYLEIGH_BRIGHTNESS         3.3
#define MIE_BRIGHTNESS              0.1
#define MIE_DISTRIBUTION            0.63
#define STEP_COUNT                  15.0
#define SCATTER_STRENGTH            0.028
#define RAYLEIGH_STRENGTH           0.139
#define MIE_STRENGTH                0.0264
#define RAYLEIGH_COLLECTION_POWER	0.81
#define MIE_COLLECTION_POWER        0.39

#define SUNSPOT_BRIGHTNESS          500
#define MOONSPOT_BRIGHTNESS         25

#define SKY_SATURATION              1.5

#define SURFACE_HEIGHT              0.98

#define PI 3.14159

/* DRAWBUFFERS:0 */

layout (location = 0) out vec4 albedo;

uniform sampler2D texture;
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform sampler2D depthtex0;                    
uniform int worldTime;

in vec2 uv;
in vec2 texcoord;
in vec4 color;
in vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
}

void main() {
    vec3 color;
    	if (starData.a > 0.5) {
		color = starData.rgb;
	}
	else {
		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
		color = calcSkyColor(normalize(pos.xyz));
	}

    albedo = vec4(color, 1.0);
}