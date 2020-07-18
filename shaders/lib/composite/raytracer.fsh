bool raytraceIntersection(vec3 pos, vec3 vec, out vec3 screenSpace, vec3 screenPos) {
	const float maxSteps  = 32;
	const float maxRefs   = 2;
	const float stepSize  = 0.5;
	const float stepScale = 1.6;
	const float refScale  = 0.5;

	const float maxlength = 1.0 / maxSteps;
	const float minlength = maxlength * 0.01;
	vec3 dir = normalize(viewSpaceToScreenSpace(vec + pos) - screenPos);
	float stepweight = 1.0 / abs(dir.z);
	float steplength = maxlength;
	vec3 increment = dir * maxlength;
	screenSpace = screenPos + increment; 
	float screenZ = texture(depthtex1, screenSpace.xy).r;

	uint refinements = 0;
	for (uint i = 0; i < maxSteps; i++) {

		if (any(greaterThan(abs(screenSpace.xy - 0.5), vec2(0.5)))) return false;

		if (screenSpace.z > screenZ) {
			// Do refinements

			if (refinements < maxRefs) {
				screenSpace -= increment;
				increment *= refScale;
				refinements++;

				continue;
			}
			float linearZ = linearizeDepth(screenSpace.z);
			float linearD = linearizeDepth(screenZ);
			float diff    =  abs(linearZ - linearD) / -linearZ;

			// Refinements are done, so make sure we ended up reasonably close
			if (any(greaterThan(abs(screenSpace.xy - 0.5), vec2(0.5))) || screenZ == 1.0) return false;
			if(diff < 0.1 && linearZ < 0.0) {
			return true;
			}
		}
		steplength = clamp(abs(screenZ - screenSpace.z) * stepweight, minlength, maxlength);
		screenSpace += dir * steplength;
		screenZ = texture(depthtex1, screenSpace.xy).r;
	}
	
	return false;
}
