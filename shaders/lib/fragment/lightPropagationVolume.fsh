const float aspectRatio = 2.0;
int pixels = int(viewWidth * viewHeight);
int layers = int(pow(pixels / (aspectRatio * aspectRatio), 1.0/3.0));// want layers^3 * aspectRatio^2 <= pixels
ivec3 lpv_diameter = ivec3(aspectRatio * layers, layers, aspectRatio * layers);

bool isInPropagationVolume(ivec3 voxelIndex) {
	ivec3 maxBounds =  lpv_diameter / 2;
	ivec3 minBounds = -lpv_diameter / 2;
	return voxelIndex.x > minBounds.x && voxelIndex.y > minBounds.y && voxelIndex.z > minBounds.z
	    && voxelIndex.x < maxBounds.x && voxelIndex.y < maxBounds.y && voxelIndex.z < maxBounds.z;
}

vec3 sceneSpaceToLPVSpace(vec3 scenePosition) {
	scenePosition -= 0.5;
	scenePosition += fract(cameraPosition);
	return scenePosition;
}

ivec2 getLPVStoragePos(ivec3 voxelIndex) { // in pixels/texels
	voxelIndex += lpv_diameter / 2;
	int idx1D = voxelIndex.x * lpv_diameter.y * lpv_diameter.z + voxelIndex.y * lpv_diameter.z + voxelIndex.z;
	return ivec2(idx1D % int(viewWidth), idx1D / int(viewWidth));
}
ivec3 lpvStoragePosToLPVIndex(ivec2 storagePos) { // in pixels/texels
	int idx1D = storagePos.x + storagePos.y * int(viewWidth);
	ivec3 voxelIndex = (idx1D / ivec3(lpv_diameter.y * lpv_diameter.z, lpv_diameter.z, 1)) % lpv_diameter;
	voxelIndex -= lpv_diameter / 2;
	return voxelIndex;
}

vec3 GetLight(ivec3 lpvIndex) {
	#if PROGRAM == PROGRAM_COMPOSITE
	lpvIndex += ivec3(floor(cameraPosition) - floor(previousCameraPosition));
	#endif
	if (!isInPropagationVolume(lpvIndex)) return vec3(0.0);

	ivec2 storagePos = getLPVStoragePos(lpvIndex);

	return texelFetch(colortex4, storagePos, 0).rgb;
}

vec3 GetLight(vec3 lpvPosition) {
	ivec3 lpvIndex = ivec3(floor(lpvPosition));
	vec3 lerp = lpvPosition - lpvIndex;

	vec3 lightLoYLoZ = mix(GetLight(lpvIndex + ivec3(0,0,0)), GetLight(lpvIndex + ivec3(1,0,0)), lerp.x);
	vec3 lightLoYHiZ = mix(GetLight(lpvIndex + ivec3(0,0,1)), GetLight(lpvIndex + ivec3(1,0,1)), lerp.x);
	vec3 lightHiYLoZ = mix(GetLight(lpvIndex + ivec3(0,1,0)), GetLight(lpvIndex + ivec3(1,1,0)), lerp.x);
	vec3 lightHiYHiZ = mix(GetLight(lpvIndex + ivec3(0,1,1)), GetLight(lpvIndex + ivec3(1,1,1)), lerp.x);

	vec3 lightLoZ = mix(lightLoYLoZ, lightHiYLoZ, lerp.y);
	vec3 lightHiZ = mix(lightLoYHiZ, lightHiYHiZ, lerp.y);

	return mix(lightLoZ, lightHiZ, lerp.z) + 0.2;//lightmap;
}
