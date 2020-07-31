#version 420 compatibility

//--// Outputs //----------------------------------------------------------------------------------------//

out float isSun;

out vec2 uv;

out vec3 viewDir, sunDir;

//--// Inputs //-----------------------------------------------------------------------------------------//

layout (location = 0) in vec4 vertexPosition;
layout (location = 8) in vec4 vertexUV;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform vec3 sunPosition;

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
	gl_Position = gl_ModelViewMatrix * vertexPosition;

	isSun = step(0.0, dot(gl_Position.xyz, sunPosition));

	viewDir = gl_Position.xyz;
	sunDir = sunPosition * 0.01;

	uv = (gl_TextureMatrix[0] * vertexUV).st;

	gl_Position = gl_ProjectionMatrix * gl_Position;
}
