vec3 calculateBlockLight(float mask) {
	float dist = max((1 - mask) * 16 - 1, 0.0);
	mask = mask / (dist * dist + 1);

	vec3 light = LUMINANCE_BLOCK * vec3(1.00, 0.50, 0.20) * mask;
	return light;
}
