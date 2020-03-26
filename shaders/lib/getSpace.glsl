float depth = 0.5;

vec4 getCameraPosition(in vec2 coord) {
    float getdepth = depth;
	    vec4 positionNdcSpace = vec4(coord.s * 2.0 - 1.0, coord.t * 2.0 - 1.0, 2.0 * getdepth - 1.0, 1.0);
        vec4 positionCameraSpace = gbufferProjectionInverse * positionNdcSpace;

	return positionCameraSpace / positionCameraSpace.w;
}  //get CameraSpace

vec4 getWorldSpacePosition(in vec2 coord) {
	vec4 cameraPos = getCameraPosition(coord);
	vec4 worldPos = gbufferModelViewInverse * cameraPos;
	worldPos.xyz += cameraPosition;

	return worldPos;
}// get worldSpace