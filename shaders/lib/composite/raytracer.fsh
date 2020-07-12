bool raytraceIntersection(vec3 pos, vec3 vec, out vec3 screenSpace, out vec3 viewSpace) {
	const float maxSteps  = 32;
	const float maxRefs   = 2;
	const float stepSize  = 0.5;
	const float stepScale = 1.6;
	const float refScale  = 0.1;

	vec3 increment = vec * stepSize;

	viewSpace = pos;

	uint refinements = 0;
	for (uint i = 0; i < maxSteps; i++) {
		viewSpace  += increment;
		screenSpace = viewSpaceToScreenSpace(viewSpace);

		if (any(greaterThan(abs(screenSpace - 0.5), vec3(0.5)))) return false;

		float screenZ = texture(depthtex1, screenSpace.xy).r;
		float diff    = viewSpace.z - linearizeDepth(screenZ);

		if (diff <= 0.0) {
			// Do refinements

			if (refinements < maxRefs) {
				viewSpace -= increment;
				increment *= refScale;
				refinements++;

				continue;
			}

			// Refinements are done, so make sure we ended up reasonably close
			if (any(greaterThan(abs(screenSpace - 0.5), vec3(0.5))) || length(increment) * 10 < -diff || screenZ == 1.0) return false;

			return true;
		}

		increment *= stepScale;
	}

	return false;
}
