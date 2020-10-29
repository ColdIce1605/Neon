// Octahedral Unit Vector
// Intuitive, fast, and has very little error.
vec2 encodeNormal(vec3 normal) {
	// Scale down to octahedron, project onto XY plane
	normal.xy /= abs(normal.x) + abs(normal.y) + abs(normal.z);
	// Reflect -Z hemisphere folds over the diagonals
	return normal.z <= 0.0 ? (1.0 - abs(normal.yx)) * vec2(normal.x >= 0.0 ? 1.0 : -1.0, normal.y >= 0.0 ? 1.0 : -1.0) : normal.xy;
}
vec3 decodeNormal(vec2 encoded) {
	// Exctract Z component
	vec3 normal = vec3(encoded, 1.0 - abs(encoded.x) - abs(encoded.y));
	// Reflect -Z hemisphere folds over the diagonals
	float t = max(-normal.z, 0.0);
	normal.xy += vec2(normal.x >= 0.0 ? -t : t, normal.y >= 0.0 ? -t : t);
	// Normalize and return
	return normalize(normal);
}

// Near-32F range, with only as much precision as is usually needed for color.
vec4 encodeRGBE8(vec3 rgb) {
	float exponentPart = floor(log2(max(max(rgb.r, rgb.g), rgb.b)));
	vec3  mantissaPart = clamp((128.0 / 255.0) * exp2(-exponentPart) * rgb, 0.0, 1.0);
	      exponentPart = clamp((exponentPart + 127.0) / 255.0, 0.0, 1.0);

	return vec4(mantissaPart, exponentPart);
}
vec3 decodeRGBE8(vec4 rgbe) {
	return exp2(rgbe.a * 255.0 - 127.0) * (510.0 / 256.0) * rgbe.rgb;
}
