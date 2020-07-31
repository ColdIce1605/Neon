#version 420 compatibility

//--// Inputs //-----------------------------------------------------------------------------------------//

layout (location = 0) in vec4 position;

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
	float posLen = length(position.xyz);

	// Only draw stars
	if (posLen > 100.0 && posLen < 100.1) gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * position;
	else gl_Position = vec4(1.0);
}
