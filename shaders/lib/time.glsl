vec4 CalculateTimeVector() {
	vec2 noonNight = vec2(
		0.25 - clamp(sunAngle, 0.0, 0.5),
		0.75 - clamp(sunAngle, 0.5, 1.0)
);
	vec4 timeVector = vec4(0.0);
	    timeVector.y = saturate(pow(abs(noonNight.y) * 4.0, 128.0));
	return timeVector;
}