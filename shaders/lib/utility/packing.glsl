// As far as I know, this is the fastest possible method for pack2x8 and unpack2x8
float pack2x8(vec2 x) {
	// Note that the x component is not rounded here, as it is automatically
	// rounded correctly when writing to a 16UNORM buffer.
	x.y = floor(255.0 * x.y + 0.5);
	return dot(x, vec2(255.0 / 65535.0, 256.0 / 65535.0));
} float pack2x8(float x, float y) { return pack2x8(vec2(x, y)); }

float pack2x8Dithered(vec2 x, float pattern) {
	// Dithered version of pack2x8, has to manually round the x component
	x = floor(255.0 * x + pattern);
	return dot(x, vec2(1.0 / 65535.0, 256.0 / 65535.0));
} float pack2x8Dithered(float x, float y, float pattern) { return pack2x8Dithered(vec2(x, y), pattern); }

vec2 unpack2x8(float pack) {
	pack *= 65535.0 / 256.0;
	vec2 xy; xy.y = floor(pack); xy.x = pack - xy.y;
	return vec2(256.0 / 255.0, 1.0 / 255.0) * xy;
}
void unpack2x8(float pack, out float x, out float y) {
	vec2 xy = unpack2x8(pack);
	x = xy.x; y = xy.y;
}
float unpack2x8X(float x) { return (256.0 / 255.0) * fract(x * (65535.0 / 256.0)); }
float unpack2x8Y(float x) { return floor(x * (65535.0 / 256.0)) / 255.0; }

float pack2x4(vec2 x) {
	x = round(x * 15.0);
	return dot(x, vec2(1.0 / 255.0, 16.0 / 255.0));
}
vec2 unpack2x4(float pack) {
	pack *= 255.0 / 16.0;
	vec2 xy; xy.y = floor(pack); xy.x = pack - xy.y;
	return vec2(16.0 / 15.0, 1.0 / 15.0) * xy;
}
