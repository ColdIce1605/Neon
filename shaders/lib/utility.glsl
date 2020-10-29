// Common constants
const float tau         = radians(360.0);
const float pi          = radians(180.0);
const float hpi         = radians( 90.0);
const float phi         = sqrt(5.0) * 0.5 + 0.5;
const float goldenAngle = tau / (phi + 1.0);

const float ln2         = log(2.0);

const mat2 rotateGoldenAngle = mat2(cos(goldenAngle), -sin(goldenAngle), sin(goldenAngle), cos(goldenAngle));

//--// Helpers (mainly exist to give cleaner and/or clearer code)

// Clamps each component of x between 0 and 1. Generally free on instruction output.
#define clamp01(x) clamp(x, 0.0, 1.0)

// Swaps two variables of the same type
void swap(inout float x, inout float y) { float temp = x; x = y; y = temp; }
void swap(inout vec2  x, inout vec2  y) { vec2  temp = x; x = y; y = temp; }
void swap(inout vec3  x, inout vec3  y) { vec3  temp = x; x = y; y = temp; }
void swap(inout vec4  x, inout vec4  y) { vec4  temp = x; x = y; y = temp; }

// Min and max component of a vector
float maxof(vec2 x) { return max(x.x, x.y); }
float maxof(vec3 x) { return max(max(x.x, x.y), x.z); }
float maxof(vec4 x) { return max(max(x.x, x.y), max(x.z, x.w)); }
float minof(vec2 x) { return min(x.x, x.y); }
float minof(vec3 x) { return min(min(x.x, x.y), x.z); }
float minof(vec4 x) { return min(min(x.x, x.y), min(x.z, x.w)); }

// Sum of the components of a vector
float sumof(vec2 x) { return x.x + x.y; }
float sumof(vec3 x) { return x.x + x.y + x.z; }
float sumof(vec4 x) { x.xy += x.zw; return x.x + x.y; }

// Matrix diagonal
vec2 diagonal(mat2 m) { return vec2(m[0].x, m[1].y); }
vec3 diagonal(mat3 m) { return vec3(m[0].x, m[1].y, m[2].z); }
vec4 diagonal(mat4 m) { return vec4(m[0].x, m[1].y, m[2].z, m[3].w); }

// Sine & cosine of x in a vec2
vec2 sincos(float x) { return vec2(sin(x), cos(x)); }

// Solid angle and cone angle conversion
#define coneAngleToSolidAngle(x) (tau * (1.0 - cos(x)))
#define solidAngleToConeAngle(x) acos(1.0 - (x) / tau)

//--// Uncategorized stuff

// A sort of smooth minimum.
// value is n when x == 0, x when x >= m.
// slope is 0 when x == 0, 1 when x >= m.
float almostIdentity(float x, float m, float n) {
	if (x >= m) { return x; }
	x /= m;
	return ((2.0 * n - m) * x + (2.0 * m - 3.0 * n)) * x * x + n;
}

vec2 circlemap(float index, float count) {
	// follows fermat's spiral with a divergence angle equal to the golden angle
	return sincos(index * goldenAngle) * sqrt(index / count);
}

// Similar to smoothstep, but using linear interpolation instead of Hermite interpolation.
float linearstep(float e0, float e1, float x) {
	return clamp((x - e0) / (e1 - e0), 0.0, 1.0);
}
vec2 linearstep(vec2 e0, vec2 e1, vec2 x) {
	return clamp((x - e0) / (e1 - e0), 0.0, 1.0);
}

// This is just a renamed version of Jodie's blackbody() function that you can find on shaderlabs
vec3 planckianLocus(float t) {
	// http://en.wikipedia.org/wiki/Planckian_locus

	vec4 vx = vec4(-0.2661239e9,-0.2343580e6,0.8776956e3,0.179910);
	vec4 vy = vec4(-1.1063814,-1.34811020,2.18555832,-0.20219683);
	float it = 1./t;
	float it2= it*it;
	float x = dot(vx,vec4(it*it2,it2,it,1.));
	float x2 = x*x;
	float y = dot(vy,vec4(x*x2,x2,x,1.));
	float z = 1. - x - y;

	// http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
	mat3 xyzToSrgb = mat3(
		 3.2404542,-1.5371385,-0.4985314,
		-0.9692660, 1.8760108, 0.0415560,
		 0.0556434,-0.2040259, 1.0572252
	);

	vec3 srgb = vec3(x/y,1.,z/y) * xyzToSrgb;
	return max(srgb,0.);
}

// Calculates light interference caused by reflections on and inside of a (very) thin film.
// Can technically be used at larger scales, but interference is practically non-existent in these cases.
vec3 thinFilmInterference(const float filmThickness /* In nanometers */, const float filmRefractiveIndex, float theta2) {
	const vec3 wavelengths = vec3(612.5, 549.0, 451.0); // should probably be an input

	float opd = 2.0 * filmRefractiveIndex * filmThickness * cos(theta2);

	return 2.0 * abs(cos(opd * pi / wavelengths)); // 99% sure this is correct.
}
