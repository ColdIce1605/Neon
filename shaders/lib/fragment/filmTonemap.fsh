#define TONEMAP_TOE_STRENGTH      0.1 // [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define TONEMAP_TOE_LENGTH        0.2 // [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define TONEMAP_SHOULDER_STRENGTH 0.5 // [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define TONEMAP_SHOULDER_LENGTH   4.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5.0]
#define TONEMAP_SHOULDER_ANGLE    0.2 // [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]

/*\
 * For details see http://filmicworlds.com/blog/filmic-tonemapping-with-piecewise-power-curves/
 * Note that shoulderStrength here is shoulderLength on that page.
 *
 * Possible future change: Separate settings for each channel.
\*/

//--// Structs

struct userParameters {
	float toeStrength;
	float toeLength;
	float shoulderStrength;
	float shoulderLength;
	float shoulderAngle;
};

struct segmentParameters {
	float lnA;
	float B;
	vec2 offset;
	vec2 scale;
};

struct curveParameters {
	vec2 p0;
	vec2 p1;
	float w;
	vec2 overshoot;
	segmentParameters[3] segments;
};

//--// Curve evaluation

float evalCurveSegment(float x, const segmentParameters segment) {
	x = (x - segment.offset.x) * segment.scale.x;
	x = x > 0.0 ? exp(segment.lnA + (segment.B * log(x))) : 0.0;
	return segment.scale.y * x + segment.offset.y;
}
float evalCurveSegmentInv(float y, const segmentParameters segment) {
	y = (y - segment.offset.y) / segment.scale.y;
	y = y > 0.0 ? exp((log(y) - segment.lnA) / segment.B) : 0.0;
	return (y / segment.scale.x) + segment.offset.x;
}

float evalFullCurve(float x, const curveParameters curve) {
	int index = x < curve.p0.x ? 0 : (x < curve.p1.x ? 1 : 2);
	return evalCurveSegment(x, curve.segments[index]);
}
float evalFullCurveInv(float y, const curveParameters curve) {
	int index = y < curve.p0.y ? 0 : (y < curve.p1.y ? 1 : 2);
	return evalCurveSegmentInv(y, curve.segments[index]);
}

//--// Curve paramter derivation (only for reference, these functions are not actually used, instead I derive the parameters with a lot of constants in the main tonemap function)

/*
void solveAB(vec2 p0, float m, out float lnA, out float B) {
	B = (m * p0.x) / p0.y;
	lnA = log(p0.y) - B * log(p0.x);
}

curveParameters deriveCurveParameters(const userParameters params) {
	curveParameters curve;

	//--// Toe Params

	// Square toeLength to avoid having to input extremely small values for short toes
	curve.p0.x =  0.5 * params.toeLength * params.toeLength;
	curve.p0.y = (1.0 - params.toeStrength) * curve.p0.x;

	//--// Shoulder Params

	curve.p1 = curve.p0 + (1.0 - params.shoulderStrength) * (1.0 - curve.p0.y);
	curve.w  = curve.p0.x + (1.0 - curve.p0.y) + exp2(params.shoulderLength) - 1.0;

	curve.overshoot.x = 2.0 * curve.w * params.shoulderAngle * params.shoulderLength;
	curve.overshoot.y = 0.5 * params.shoulderAngle * params.shoulderLength;

	//--// Segments

	vec2 dp = curve.p1 - curve.p0;
	float m = dp.y != 0.0 ? dp.y / dp.x : 1.0;

	// Toe segment
	solveAB(curve.p0, m, curve.segments[0].lnA, curve.segments[0].B);
	curve.segments[0].offset = vec2(0.0);
	curve.segments[0].scale = vec2(1.0);
	// Linear segment
	curve.segments[1].lnA = log(m);
	curve.segments[1].B = 1.0;
	curve.segments[1].offset = vec2(-curve.p0.y / m + curve.p0.x, 0.0);
	curve.segments[1].scale = vec2(1.0);
	// Shoulder segment
	solveAB(1.0 + curve.overshoot - curve.p1, m, curve.segments[2].lnA, curve.segments[2].B);
	curve.segments[2].offset = 1.0 + curve.overshoot;
	curve.segments[2].scale = vec2(-1.0);

	// Normalize to ensure that when X=W, Y=1
	float invScale = 1.0 / evalCurveSegment(curve.w, curve.segments[2]);
	curve.segments[0].offset.y *= invScale;
	curve.segments[0].scale.y  *= invScale;
	curve.segments[1].offset.y *= invScale;
	curve.segments[1].scale.y  *= invScale;
	curve.segments[2].offset.y *= invScale;
	curve.segments[2].scale.y  *= invScale;

	return curve;
}
*/

//--// Main tonemap function

vec3 tonemap(vec3 color) {
	const userParameters params = userParameters(TONEMAP_TOE_STRENGTH, TONEMAP_TOE_LENGTH, TONEMAP_SHOULDER_STRENGTH, TONEMAP_SHOULDER_LENGTH, TONEMAP_SHOULDER_ANGLE);

	//--// Derive curve

	// Square toeLength to avoid having to input extremely small values for short toes
	const vec2 p0 = vec2(0.5 * params.toeLength * params.toeLength, (1.0 - params.toeStrength) * 0.5 * params.toeLength * params.toeLength);
	const vec2 p1 = p0 + (1.0 - params.shoulderStrength) * (1.0 - p0.y);
	const float w = p0.x + (1.0 - p0.y) + exp2(params.shoulderLength) - 1.0;
	const vec2 overshoot = vec2(2.0 * w * params.shoulderAngle * params.shoulderLength, 0.5 * params.shoulderAngle * params.shoulderLength);

	const vec2 dp = p1 - p0;
	const float m = dp.y != 0.0 ? dp.y / dp.x : 1.0;

	const segmentParameters toeSegment = segmentParameters(log(p0.y) - (m * p0.x / p0.y) * log(p0.x), m * p0.x / p0.y, vec2(0.0), vec2(1.0));
	const segmentParameters linearSegment = segmentParameters(log(m), 1.0, vec2(-p0.y / m + p0.x, 0.0), vec2(1.0));
	const vec2 p1s = 1.0 + overshoot - p1;
	const segmentParameters shoulderSegment = segmentParameters(log(p1s.y) - (m * p1s.x / p1s.y) * log(p1s.x), m * p1s.x / p1s.y, 1.0 + overshoot, vec2(-1.0));

	const segmentParameters[3] segments = segmentParameters[3](toeSegment, linearSegment, shoulderSegment);

	// Normalize to ensure that when X=W, Y=1
	const float invScale = 1.0 / (-(segments[2].offset.x - w > 0.0 ? exp(segments[2].lnA + (segments[2].B * log(segments[2].offset.x - w))) : 0.0) + segments[2].offset.y);

	const segmentParameters[3] normSegments = segmentParameters[3](
		segmentParameters(segments[0].lnA, segments[0].B, segments[0].offset * vec2(1.0, invScale), segments[0].scale * vec2(1.0, invScale)),
		segmentParameters(segments[1].lnA, segments[1].B, segments[1].offset * vec2(1.0, invScale), segments[1].scale * vec2(1.0, invScale)),
		segmentParameters(segments[2].lnA, segments[2].B, segments[2].offset * vec2(1.0, invScale), segments[2].scale * vec2(1.0, invScale))
	);

	const curveParameters curve = curveParameters(p0, p1, w, overshoot, normSegments);

	//--// Apply curve

	color.r = evalFullCurve(color.r, curve);
	color.g = evalFullCurve(color.g, curve);
	color.b = evalFullCurve(color.b, curve);

	return color;
}
vec3 tonemapInv(vec3 color) {
	const userParameters params = userParameters(TONEMAP_TOE_STRENGTH, TONEMAP_TOE_LENGTH, TONEMAP_SHOULDER_STRENGTH, TONEMAP_SHOULDER_LENGTH, TONEMAP_SHOULDER_ANGLE);

	//--// Derive curve

	// Square toeLength to avoid having to input extremely small values for short toes
	const vec2 p0 = vec2(0.5 * params.toeLength * params.toeLength, (1.0 - params.toeStrength) * 0.5 * params.toeLength * params.toeLength);
	const vec2 p1 = p0 + (1.0 - params.shoulderStrength) * (1.0 - p0.y);
	const float w = p0.x + (1.0 - p0.y) + exp2(params.shoulderLength) - 1.0;
	const vec2 overshoot = vec2(2.0 * w * params.shoulderAngle * params.shoulderLength, 0.5 * params.shoulderAngle * params.shoulderLength);

	const vec2 dp = p1 - p0;
	const float m = dp.y != 0.0 ? dp.y / dp.x : 1.0;

	const segmentParameters toeSegment = segmentParameters(log(p0.y) - (m * p0.x / p0.y) * log(p0.x), m * p0.x / p0.y, vec2(0.0), vec2(1.0));
	const segmentParameters linearSegment = segmentParameters(log(m), 1.0, vec2(-p0.y / m + p0.x, 0.0), vec2(1.0));
	const vec2 p1s = 1.0 + overshoot - p1;
	const segmentParameters shoulderSegment = segmentParameters(log(p1s.y) - (m * p1s.x / p1s.y) * log(p1s.x), m * p1s.x / p1s.y, 1.0 + overshoot, vec2(-1.0));

	const segmentParameters[3] segments = segmentParameters[3](toeSegment, linearSegment, shoulderSegment);

	// Normalize to ensure that when X=W, Y=1
	const float invScale = 1.0 / (-(segments[2].offset.x - w > 0.0 ? exp(segments[2].lnA + (segments[2].B * log(segments[2].offset.x - w))) : 0.0) + segments[2].offset.y);

	const segmentParameters[3] normSegments = segmentParameters[3](
		segmentParameters(segments[0].lnA, segments[0].B, segments[0].offset * vec2(1.0, invScale), segments[0].scale * vec2(1.0, invScale)),
		segmentParameters(segments[1].lnA, segments[1].B, segments[1].offset * vec2(1.0, invScale), segments[1].scale * vec2(1.0, invScale)),
		segmentParameters(segments[2].lnA, segments[2].B, segments[2].offset * vec2(1.0, invScale), segments[2].scale * vec2(1.0, invScale))
	);

	const curveParameters curve = curveParameters(p0, p1, w, overshoot, normSegments);

	//--// Apply curve

	color.r = evalFullCurveInv(color.r, curve);
	color.g = evalFullCurveInv(color.g, curve);
	color.b = evalFullCurveInv(color.b, curve);

	return color;
}
