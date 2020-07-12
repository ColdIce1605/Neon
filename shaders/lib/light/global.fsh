float diffuseOrenNayar(vec3 light, vec3 normal, vec3 view, float roughness) {
	float NoL = dot(normal, light);
	float NoV = dot(normal, view);

	vec2 angles = acos(vec2(NoL, NoV));

	// Calculate angles.x, angles.y, and gamma
	if (angles.x < angles.y) angles = angles.yx;
	float gamma = dot(view - normal * NoV, light - normal * NoL);

	float roughnessSquared = roughness * roughness;

	// These used multiple times.
	float t1 = roughnessSquared / (roughnessSquared + 0.09);
	float t2 = (2.0 / PI) * angles.y;
	float t3 = max(0.0, NoL);

	// Calculate C1, C2, and C3
	float C1 = 1.0 - 0.5 * (roughnessSquared / (roughnessSquared + 0.33));
	float C2 = 0.450 * t1;
	float C3 = (4.0 * angles.x * angles.y) / (PI * PI); C3 = 0.125 * t1 * C3 * C3;

	// Complete C2
	if(gamma >= 0.0) C2 *= sin(angles.x);
	else {
		float part = sin(angles.x) - t2;
		C2 *= part * part * part;
	}

	// Calculate P1 and P2
	float p1 = gamma * C2 * tan(angles.y);
	float p2 = (1.0 - abs(gamma)) * C3 * tan((angles.x + angles.y) / 2.0);

	// Calculate L1 and L2
	float L1 = t3 * (C1 + p1 + p2);
	float L2 = 0.17 * t3 * (roughnessSquared / (roughnessSquared + 0.13)) * (1.0 - gamma * (t2 * t2));

	return max(0.0, L1 + L2) / PI;
}
#define calculateDiffuse(x, y, z, w) diffuseOrenNayar(x, y, z, w)

#define SHADOW_SAMPLING_TYPE 1 // 0 = Single sample. 1 = 12-sample soft shadows. 2 = PCSS. [0 1 2]

#if SHADOW_SAMPLING_TYPE == 0
float sampleShadows(vec3 coord) {
	float shadow = texture(shadowtex1, coord);

	return shadow * shadow;
}
#elif SHADOW_SAMPLING_TYPE == 1
float sampleShadowsSoft(vec3 coord) {
	const vec2[12] offset = vec2[12](
		                 vec2(-0.5, 1.5), vec2( 0.5, 1.5),
		vec2(-1.5, 0.5), vec2(-0.5, 0.5), vec2( 0.5, 0.5), vec2( 1.5, 0.5),
		vec2(-1.5,-0.5), vec2(-0.5,-0.5), vec2( 0.5,-0.5), vec2( 1.5,-0.5),
		                 vec2(-0.5,-1.5), vec2( 0.5,-1.5)
	);
	vec2 resolution = textureSize(shadowtex1, 0);

	float shadow = 0.0;
	for (int i = 0; i < offset.length(); i++) {
		shadow += texture(shadowtex1, coord + vec3(offset[i] / resolution, 0));
	}
	shadow /= offset.length(); shadow *= shadow;

	return shadow;
}
#elif SHADOW_SAMPLING_TYPE == 2
float calculatePCSSSpread(
	float angle,       // Angular radius of the light, in radians.
	float mapDiameter, // Diameter of the shadow map.
	float mapDepth     // Depth of the shadow map.
) {
	return tan(angle) * mapDepth / mapDiameter;
}

float sampleShadowsPCSS(vec3 coord, float distortionScale) {
	// Sampling offsets (Poisson disk w. noise)
	const vec2[36] offset = vec2[36](
		vec2(-0.90167680,  0.34867350),
		vec2(-0.98685560, -0.03261871),
		vec2(-0.67581730,  0.60829530),
		vec2(-0.47958790,  0.23570540),
		vec2(-0.45314310,  0.48728980),
		vec2(-0.30706600, -0.15843290),
		vec2(-0.09606075, -0.01807100),
		vec2(-0.60807480,  0.01524314),
		vec2(-0.02638345,  0.27449020),
		vec2(-0.17485240,  0.49767420),
		vec2( 0.08868586, -0.19452260),
		vec2( 0.18764890,  0.45603400),
		vec2( 0.39509670,  0.07532994),
		vec2(-0.14323580,  0.75790890),
		vec2(-0.52281310, -0.28745570),
		vec2(-0.78102060, -0.44097930),
		vec2(-0.40987180, -0.51410110),
		vec2(-0.12428560, -0.78665660),
		vec2(-0.52554520, -0.80657600),
		vec2(-0.01482044, -0.48689910),
		vec2(-0.45758520,  0.83156060),
		vec2( 0.18829080,  0.71168610),
		vec2( 0.23589650, -0.95054530),
		vec2( 0.26197550, -0.61955050),
		vec2( 0.47952230,  0.32172530),
		vec2( 0.52478220,  0.61679990),
		vec2( 0.85708400,  0.47555550),
		vec2( 0.75702890,  0.08125463),
		vec2( 0.48267020,  0.86368290),
		vec2( 0.33045960, -0.31044460),
		vec2( 0.59658700, -0.35501270),
		vec2( 0.69684450, -0.61393110),
		vec2( 0.88014110, -0.41306840),
		vec2( 0.07468465,  0.99449370),
		vec2( 0.92697510, -0.10826900),
		vec2( 0.45471010, -0.78973980)
	);

	//--//

	// Shadow map properties

	float mapRadius = shadowProjectionInverse[1].y;
	float mapDepth  = shadowProjectionInverse[2].z * -8.0;
	int mapResolution = textureSize(shadowtex0, 0).x;

	// Calculate spread
	float spread = calculatePCSSSpread(radians(0.25), 2.0 * mapRadius, mapDepth) / distortionScale;

	// Noise
	float noiseAngle = noise1(gl_FragCoord.st) * TAU;
	mat2 rot = mat2(cos(noiseAngle), sin(noiseAngle), -sin(noiseAngle), cos(noiseAngle));

	//--//

	float depthAverage = 0.0;
	for (int i = 0; i < offset.length(); i++) {
		vec2 scoord = coord.xy + (rot * offset[i] * 0.04 / mapRadius);

		vec4 depthSamples = textureGather(shadowtex0, scoord);

		depthAverage += sumof(max(vec4(0.0), coord.z - depthSamples));
	}
	depthAverage /= offset.length() * 4;

	float penumbraSize = max(depthAverage * spread, 1.0 / mapResolution);

	float shadow = 0.0;
	for (int i = 0; i < offset.length(); i++) {
		vec3 scoord = vec3(coord.st + (rot * offset[i] * penumbraSize), coord.p);

		shadow += textureLod(shadowtex1, scoord, 0);
	}

	return shadow / offset.length();
}
#endif

#ifdef HSSRS
float calculateHSSRS(vec3 viewSpace, vec3 lightVector) {
	vec3 increment = lightVector * HSSRS_RAY_LENGTH / HSSRS_RAY_STEPS;

	for (uint i = 0; i < HSSRS_RAY_STEPS; i++) {
		viewSpace += increment;

		vec3 screenSpace = viewSpaceToScreenSpace(viewSpace);
		if (any(greaterThan(abs(screenSpace - 0.5), vec3(0.5)))) return 1.0;

		float diff = viewSpace.z - linearizeDepth(texture(depthtex1, screenSpace.xy).r);
		if (diff < 0.005 * viewSpace.z && diff > 0.05 * viewSpace.z) return i / HSSRS_RAY_STEPS;
	}

	return 1.0;
}
#endif

float calculateShadows(
	vec3 positionLocal,
	#ifdef HSSRS
	vec3 positionView,
	bool translucent,
	#endif
	vec3 normal
) {
	vec3 shadowCoord = (shadowProjection * shadowModelView * vec4(positionLocal, 1.0)).xyz;

	float distortCoeff = 1.0 + length(shadowCoord.xy);

	#ifdef HSSRS
	if (calculateHSSRS(positionView, world.globalLightVector * distortCoeff) < 1.0 && !translucent) return 0.0;
	shadowCoord.z += HSSRS_RAY_LENGTH * shadowProjection[2].z * distortCoeff;
	shadowCoord.z += 0.0002;
	#else
	float zBias = ((2.0 / shadowProjection[0].x) / textureSize(shadowtex1, 0).x) * shadowProjection[2].z;
	zBias *= min(tan(acos(abs(dot(world.globalLightVector, normal)))), 5.0);
	zBias *= mix(1.0, SQRT2, abs(shadowAngle - 0.25) * 4.0);

	#if SHADOW_SAMPLING_TYPE == 1
	zBias *= 2.5;
	#endif

	zBias *= distortCoeff * distortCoeff;
	zBias -= (0.0059 * shadowProjection[0].x) * SQRT2;

	shadowCoord.z += zBias;
	#endif

	shadowCoord.xy /= distortCoeff;
	shadowCoord.z *= 0.25;

	shadowCoord = shadowCoord * 0.5 + 0.5;

	#if SHADOW_SAMPLING_TYPE == 0
	return sampleShadows(shadowCoord);
	#elif SHADOW_SAMPLING_TYPE == 1
	return sampleShadowsSoft(shadowCoord);
	#elif SHADOW_SAMPLING_TYPE == 2
	return sampleShadowsPCSS(shadowCoord, distortCoeff);
	#endif
}

#ifdef GI
vec3 getGI(vec2 coord) {
	return texture(colortex5, coord * GI_RESOLUTION).rgb;
}
#endif

vec3 calculateGlobalLight(
	worldStruct world,
	surfaceStruct surface
	#ifdef COMPOSITE
	, float shadows
	#endif
) {
	bool translucent =
	   surface.mat.id ==  18 // Leaves
	|| surface.mat.id ==  30 // Cobweb
	|| surface.mat.id ==  31 // Tall grass and fern
	|| surface.mat.id ==  37 // Flowers
	|| surface.mat.id ==  59 // Crops
	|| surface.mat.id ==  83 // Sugar canes
	|| surface.mat.id == 106 // Vines
	|| surface.mat.id == 111 // Lily pad
	|| surface.mat.id == 175 // Double plants
	;

	vec3 diffuse;
	if (translucent) {
		float NoL = dot(surface.normal, world.globalLightVector);

		// Not realistic but looks good.
		diffuse = mix(surface.mat.diffuse * 0.65 + 0.35, vec3(1.0), NoL * 0.5 + 0.5) * (abs(NoL) * 0.5 + 0.5) / PI;
	} else diffuse = vec3(calculateDiffuse(world.globalLightVector, surface.normal, normalize(-surface.positionView), surface.mat.roughness));

	#ifndef COMPOSITE
	float shadows = 0.0;
	#endif
	if (any(greaterThan(diffuse, vec3(0.0)))) {
		shadows = calculateShadows(
			surface.positionLocal,
			#ifdef HSSRS
			surface.positionView,
			translucent,
			#endif
			surface.normalGeom
		);
	}

	vec3 light = world.globalLightColor * diffuse * shadows;

	#ifdef GI
	light += world.globalLightColor * getGI(surface.positionScreen.xy);
	#endif

	return light;
}
