vec4 textureSmooth(sampler2D sampler, vec2 coord) {
	ivec2 res = textureSize(sampler, 0);

	coord *= res;
	vec2 fr = fract(coord);
	coord = floor(coord) + (fr * fr * (3.0 - 2.0 * fr)) + 0.5;

	return texture(sampler, coord / res);
}
