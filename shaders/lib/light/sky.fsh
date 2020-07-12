vec3 calculateSkyLight(vec3 normal, vec3 upVec, float mask) {
	float skylight = mask * mask * mask;
	skylight *= 0.4 * dot(normal, upVec) + 0.5;

	return world.globalLightColor * vec3(0.0075, 0.025, 0.05) * skylight;
}
