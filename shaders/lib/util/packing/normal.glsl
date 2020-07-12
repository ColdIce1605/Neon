vec2 packNormal(vec3 normal) {
	return normal.xy * inversesqrt(normal.z * 8.0 + 8.0) + 0.5;
}
vec3 unpackNormal(vec2 pack) {
	vec4 normal = vec4(pack * 2.0 - 1.0, 1.0, -1.0);
	normal.z    = dot(normal.xyz, -normal.xyw);
	normal.xy  *= sqrt(normal.z);
	return normal.xyz * 2.0 + vec3(0.0, 0.0, -1.0);
}
