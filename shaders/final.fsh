#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

#define FINAL

#include "/cfg/bloom.scfg"

const bool colortex4MipmapEnabled = true;

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:0 */

layout (location = 0) out vec3 finalColor;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;

in float avglum;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform sampler2D colortex4;
uniform sampler2D colortex6;

#ifdef BLOOM
uniform float viewWidth, viewHeight;
uniform sampler2D colortex5;
#endif

uniform float blindness;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/debug.glsl"

#include "/lib/preprocess.glsl"

#include "/lib/util/textureBicubic.glsl"
#include "/lib/util/productof.glsl"

#include "/lib/aces.glsl"

//--//

#ifdef BLOOM
void applyBloom(inout vec3 color) {
	vec2 px = 1.0 / vec2(viewWidth, viewHeight);

	vec3
	bloom  = textureBicubic(colortex5, (fragCoord / exp2(1)) + vec2(0.00000           , 0.00000            )).rgb * 0.475;
	bloom += textureBicubic(colortex5, (fragCoord / exp2(2)) + vec2(0.00000           , 0.50000 + px.y * 19)).rgb * 0.625;
	bloom += textureBicubic(colortex5, (fragCoord / exp2(3)) + vec2(0.25000 + px.x * 2, 0.50000 + px.y * 19)).rgb * 0.750;
	bloom += textureBicubic(colortex5, (fragCoord / exp2(4)) + vec2(0.25000 + px.x * 2, 0.62500 + px.y * 37)).rgb * 0.850;
	bloom += textureBicubic(colortex5, (fragCoord / exp2(5)) + vec2(0.31250 + px.x * 4, 0.62500 + px.y * 37)).rgb * 0.925;
	bloom += textureBicubic(colortex5, (fragCoord / exp2(6)) + vec2(0.31250 + px.x * 4, 0.65625 + px.y * 55)).rgb * 0.975;
	bloom += textureBicubic(colortex5, (fragCoord / exp2(7)) + vec2(0.46875 + px.x * 6, 0.65625 + px.y * 55)).rgb * 1.000;
	bloom /= 5.6;

	color = mix(color, bloom, BLOOM_AMOUNT * 0.5);
}
#endif

void lowLightAdapt(inout vec3 color) { 
	const float maxLumaRange = 2.5;
	const float minLumaRange = 0.00001;
  float rod = dot(color, vec3(15, 50, 35)); 
  rod *= 1.0 - pow(smoothstep(0.0, 4.0, rod), 0.01); 

  color = (rod + color) * clamp(0.3 / avglum, minLumaRange, maxLumaRange); 
} 

void tonemap(inout vec3 color) {
	color *= color;
	color /= color + 1.0;
	color  = pow(color, vec3(0.5 / GAMMA));
}

void ACESFitted(inout vec3 color)
{
    color = (color * ACESInputMat);

    // Apply RRT and ODT
    color = RRTAndODTFit(color);

    color = (color * ACESOutputMat);

    // Clamp to [0, 1]
    color = clamp01(color);
	color = pow(color, vec3(0.5 / GAMMA));
}

void vignette(inout vec3 color) {
    float dist = distance(fragCoord, vec2(0.5)) * Vignette_Strength;

    dist = pow(dist / 2.0, 1.1);

    color * (1.0 - dist);
}

void dither(inout vec3 color) {
	const mat4 pattern = mat4(
		 1,  9,  3, 11,
		13,  5, 15,  7,
		 4, 12,  2, 10,
		16,  8, 14,  6
	) / (255 * 17);

	ivec2 p = ivec2(mod(gl_FragCoord.st, 4.0));

	color += pattern[p.x][p.y];
}

void main() {
	finalColor = texture(colortex4, fragCoord).rgb;

	#ifdef BLOOM
	applyBloom(finalColor);
	#endif
	
	lowLightAdapt(finalColor);

	tonemap(finalColor);
	//ACESFitted(finalColor);
	
	vignette(finalColor);
	dither(finalColor);

	debugExit();
}