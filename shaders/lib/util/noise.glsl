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

// 	<https://www.shadertoy.com/view/MdX3Rr>
//	by inigo quilez
//
const mat2 m2 = mat2(0.8,-0.6,0.6,0.8);
float fbm( in vec2 p ){
    float f = 0.0;
    f += 0.5000*noise1( p ); p = m2*p*2.02;
    f += 0.2500*noise1( p ); p = m2*p*2.03;
    f += 0.1250*noise1( p ); p = m2*p*2.01;
    f += 0.0625*noise1( p );

    return f/0.9375;
}