#version 420

//--// Outputs //----------------------------------------------------------------------------------------//

out vec2 fragCoord;

out vec3 viewDir;
out vec3 sunDir, moonDir;

//--// Inputs //-----------------------------------------------------------------------------------------//

layout (location = 0) in vec4 vertexPosition;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform vec3 sunPosition, moonPosition;
uniform mat4 gbufferModelViewInverse, gbufferProjectionInverse;

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
	gl_Position = vertexPosition * 2.0 - 1.0;
	fragCoord = vertexPosition.xy;

	vec4 viewDir4 = gbufferProjectionInverse * vec4(gl_Position.xy, 1.0, 1.0);
	viewDir4 /= viewDir4.w;
	viewDir = mat3(gbufferModelViewInverse) * viewDir4.xyz;

	sunDir  = mat3(gbufferModelViewInverse) * sunPosition * 0.01;
	moonDir = mat3(gbufferModelViewInverse) * moonPosition * 0.01;
}
