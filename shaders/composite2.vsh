#version 420

//--// Structs //----------------------------------------------------------------------------------------//

struct worldStruct {
	vec3 globalLightVector;
	vec3 globalLightColor;
};

//--// Outputs //----------------------------------------------------------------------------------------//

out vec2 fragCoord;

out worldStruct world;

//--// Inputs //-----------------------------------------------------------------------------------------//

layout (location = 0) in vec4 vertexPosition;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform float eyeAltitude;

uniform float sunAngle, shadowAngle;

uniform vec3 shadowLightPosition;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/preprocess.glsl"
#include "/lib/lightingConstants.glsl"

//--//

float rci(vec2 pos, vec2 dir) {
	float rDot = dot(pos, dir);
	return rDot + sqrt((rDot * rDot) - dot(pos, pos) + 453063.61e9);
}
vec3 calculateAtmosphereTransmittance(float ang) {
	vec2 pos  = vec2(0.0, eyeAltitude + 6731e3),
	     incr = vec2(sin(ang), cos(ang));
	float stepsize = rci(pos, incr) / 128;
	incr *= stepsize;
	vec2 od = vec2(0.0);
	for (uint i = 0; i < 128; i++) {
		pos += incr;
		od  += exp((length(pos) - 6731e3) * vec2(-1.25e-4, -8.33e-4)) * stepsize;
	}

	return exp(mat2x3(vec3(-5.8e-6, -1.35e-5, -3.31e-5), vec3(-6e-6)) * od);
}

//--//

void main() {
	gl_Position = vertexPosition * 2.0 - 1.0;
	fragCoord = vertexPosition.xy;

	//--// Fill world struct

	world.globalLightVector = shadowLightPosition * 0.01;
	world.globalLightColor  = mix(ILLUMINANCE_MOON, ILLUMINANCE_SUN, sunAngle < 0.5) * calculateAtmosphereTransmittance(shadowAngle * TAU - (0.5 * PI));
}
