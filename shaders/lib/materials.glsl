struct material {
	int id;

	vec3 diffuse;
	vec3 specular;
	vec3 emission;

	float roughness;
	float ao;
};
const material emptyMaterial = {
	0,
	vec3(0.8),
	vec3(0.0),
	vec3(0.0),
	0.0,
	1.0
};

// Gets a material that has been packed into a single RG32F sampler.
material getPackedMaterial(sampler2D pack, vec2 coord) {
	material m = emptyMaterial;

	vec4 diff = unpackUnorm4x8(floatBitsToUint(texelFetch(pack, ivec2(coord * textureSize(pack, 0)), 0).r));
	vec4 spec = unpackUnorm4x8(floatBitsToUint(texelFetch(pack, ivec2(coord * textureSize(pack, 0)), 0).g));

	m.id        = int(diff.a * 255);
	m.diffuse   = pow(diff.rgb, vec3(2.2));
	m.specular  = vec3(spec.g * spec.g);
	m.emission  = vec3(0.0);
	m.roughness = 1.0 - spec.r; m.roughness *= m.roughness;

	return m;
}
// Gets a material.
material getMaterial(sampler2D diffuse, sampler2D specular, vec2 coord) {
	material m = emptyMaterial;

	vec4 diff = texture(diffuse,  coord);
	vec4 spec = texture(specular, coord);

	m.diffuse   = pow(diff.rgb, vec3(2.2));
	m.specular  = vec3(spec.g * spec.g);
	m.emission  = vec3(0.0);
	m.roughness = 1.0 - spec.r; m.roughness *= m.roughness;

	return m;
}
