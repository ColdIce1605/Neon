// TODO: Software implementation of the noise functions in GLSL.
// www.opengl.org/sdk/docs/man/html/noise.xhtml
// They are sadly very rarely actually implemented.

// These are currently just here so that I actually have some sort of noise function, they will probably be replaced at some point.

float noise1(vec2 coord) {
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
}
vec2 noise2(vec2 coord) {
	vec2 dps = vec2(
		dot(coord - 0.5, vec2(12.9898, 78.233)),
		dot(coord + 0.5, vec2(12.9898, 78.233))
	);

	return fract(sin(dps) * 43758.5453);
}
vec3 noise3(vec2 coord) {
	vec3 dps = vec3(
		dot(coord - 1, vec2(12.9898, 78.233)),
		dot(coord    , vec2(12.9898, 78.233)),
		dot(coord + 1, vec2(12.9898, 78.233))
	);

	return fract(sin(dps) * 43758.5453);
}
vec4 noise4(vec2 coord) {
	vec4 dps = vec4(
		dot(coord - 1.5, vec2(12.9898, 78.233)),
		dot(coord - 0.5, vec2(12.9898, 78.233)),
		dot(coord + 0.5, vec2(12.9898, 78.233)),
		dot(coord + 1.5, vec2(12.9898, 78.233))
	);

	return fract(sin(dps) * 43758.5453);
}
#define NUM_OCTAVES 5

float fbm(float x) {
	float v = 0.0;
	float a = 0.5;
	float shift = float(100);
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}


float fbm(vec2 x) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(x);
		x = rot * x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}


float fbm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100);
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}