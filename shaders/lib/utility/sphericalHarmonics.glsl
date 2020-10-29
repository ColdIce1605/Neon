vec4 calculateSphericalHarmonics(vec3 xyz) {
	const vec2 freqW = vec2(0.5 * sqrt(1.0 / pi), sqrt(3.0 / (4.0 * pi)));
	return vec4(freqW.x, freqW.y * xyz.yzx);
}

mat4x3 calculateSphericalHarmonicCoefficients(vec3 value, vec3 xyz) {
	vec4 harmonics = calculateSphericalHarmonics(xyz);
	return mat4x3(value * harmonics.x, value * harmonics.y, value * harmonics.z, value * harmonics.w);
}
vec3 valueFromSphericalHarmonics(mat4x3 coefficients, vec3 xyz) {
	vec4 harmonics = calculateSphericalHarmonics(xyz);
	return coefficients[0] * harmonics.x + coefficients[1] * harmonics.y + coefficients[2] * harmonics.z + coefficients[3] * harmonics.w;
}
