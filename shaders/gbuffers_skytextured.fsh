#version 420

/* DRAWBUFFERS:4 */

//--// Inputs //-----------------------------------------------------------------------------------------//

in float isSun;
in vec2 uv;

in vec3 viewDir, sunDir;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform sampler2D color;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/lightingConstants.glsl"

vec3 skySun() {
	return float(dot(normalize(viewDir), sunDir) > cos(radians(4.5))) * LUMINANCE_SUN * vec3(1.0, 0.96, 0.95);
}
vec3 skyMoon() {
	return pow(texture(color, uv).rgb, vec3(2.2)) * LUMINANCE_MOON;
}

void main() {
	gl_FragColor.rgb = mix(skyMoon(), skySun(), isSun);
	gl_FragColor.a = 1.0;
}
