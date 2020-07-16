float d_GGX(float NoH, float alpha) {
	float alpha2 = alpha * alpha;
	return alpha2 / (PI * pow((NoH * NoH) * (alpha2 - 1.0) + 1.0, 2.0));
}

float g_implicit(float NoI, float NoO) {
	return NoI * NoO;
}

float f_schlick(float NoI, float f0) {
	return mix(pow(1.0 - NoI, 5.0), 1.0, f0);
}

vec3 f_fresnel(float cosTheta, vec3 f0) {
	float n1 = 1.0;
	vec3 n2 = f0ToIOR(f0);

	vec3 p = sqrt(1.0 - ((n1 / n2 * n1 / n2) * (1.0 - cosTheta * cosTheta)));

	vec3 rs = ((n1 * cosTheta) - (n2 * p))
	        / ((n1 * cosTheta) + (n2 * p));
	vec3 rp = ((n1 * p) - (n2 * cosTheta))
	        / ((n1 * p) + (n2 * cosTheta));

	return mix(0.5 * (rs*rs + rp*rp), vec3(1.0), greaterThanEqual(f0, vec3(1.0)));
}

