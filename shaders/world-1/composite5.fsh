#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"
#include "/cfg/clouds.scfg"


#define COMPOSITE 5

const bool colortex4MipmapEnabled = true;

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:4 */

layout (location = 0) out vec4 composite;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;

//--// Uniforms //---------------------------------------------------------------------------------------//


uniform sampler2D colortex4;
uniform sampler2D depthtex0;

uniform float frameTimeCounter;
uniform float sunAngle;
uniform float far;
uniform float rainStrength;
uniform float viewWidth;
uniform float viewHeight;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform vec3 cameraPosition;
uniform vec3 sunPosition;


//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/debug.glsl"

#include "/lib/preprocess.glsl"
#include "/lib/lightingConstants.glsl"

#include "/lib/util/packing/normal.glsl"
#include "/lib/util/maxof.glsl"
#include "/lib/util/noise.glsl"

//--//

//https://www.shadertoy.com/view/Wd2XD1
//Created by ming in 2019-03-28
//Based on 2D Clouds by drift  https://www.shadertoy.com/view/4tdSWr
const float cloudscale = 1.45;
const float speed = 0.03;
const float ambient = 0.15;
const float intensity = 1.25;

const mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );

vec2 hash( vec2 p ) {
	p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p ) {
    p = p * cloudscale;
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
	vec2 i = floor(p + (p.x+p.y)*K1);	
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0); //vec2 of = 0.5 + 0.5*vec2(sign(a.x-a.y), sign(a.y-a.x));
    vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;
    vec3 h = max(0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot(n, vec3(70.0));	
}

float fbm(vec2 n) {
	float total = 0.0, amplitude = 0.1;
	for (int i = 0; i < 7; i++) {
		total += noise(n) * amplitude;
		n = m * n;
		amplitude *= 0.4;
	}
	return total;
}

float density(vec2 p, vec2 aspect, vec2 time)
{
    //ridged noise shape
	vec2 uv = p * aspect;
    
    float s1 = 1.0;
    
    float r = 0.0;
	uv *= s1;
    uv -= time;
    float weight = 0.8;
    for (int i=0; i<5; i++){
		r += abs(weight*noise( uv ));
        uv = m*uv + time;
		weight *= 0.7;
    }
    
    //noise shape
    float s2 = 1.2;
    
	float f = 0.0;
    uv = p * aspect;
	uv *= s2;
    uv -= time;
    weight = 0.7;
    for (int i=0; i<8; i++){
		f += weight*noise( uv );
        uv = m*uv + time;
		weight *= 0.6;
    }
    
    f *= r + f * 1.;
    f = clamp(f, 0., 1.);
    f = 1. - (1. - f) * (1. - f);
    return f;
    
}



void main() {
 vec4 color = texture(colortex4, fragCoord);
     float depth = texture2D(depthtex0, fragCoord).x;


    vec3 screenSpace = vec3(fragCoord, depth);
    vec4 t = gbufferProjectionInverse * vec4(screenSpace * 2.0 - 1.0, 1.0);
    vec3 viewSpace = t.xyz / t.w;
    vec3 playerSpace = mat3(gbufferModelViewInverse) * viewSpace;
    vec3 feetPlayerSpace = playerSpace + gbufferModelViewInverse[3].xyz;
    vec3 worldSpace = feetPlayerSpace + cameraPosition;


    #ifdef FLATCLOUDS
        if (depth == 1.0 && feetPlayerSpace.y > 15.0)
        { 
            vec2 cloudPlane = (playerSpace.xz / (playerSpace.y + 500 - normalize(cameraPosition.y)));
            vec2 aspect = vec2(viewWidth / viewHeight);
            float noise = density(cloudPlane, aspect, vec2(frameTimeCounter) * speed);
            float cloudFade = length(viewSpace) / far;
            vec3 cloudColor = mix(vec3(1.0), vec3(0.2), smoothstep(0.46, 0.52, sunAngle));
            color.rgb = mix(color.rgb, cloudColor * (1.0 - (rainStrength * 0.25)), (noise * 0.5 + 0.5) * 0.6);  
        }
    #endif

	composite = vec4(color);
}
