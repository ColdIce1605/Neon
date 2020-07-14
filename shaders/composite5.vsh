#version 420

//--// Outputs //----------------------------------------------------------------------------------------//

out vec2 fragCoord;
out vec3 EyeDirectionVector;

//--// Inputs //-----------------------------------------------------------------------------------------//

layout (location = 0) in vec4 vertexPosition;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
	gl_Position = vertexPosition * 2.0 - 1.0;
	fragCoord = vertexPosition.xy;
	
	vec4 EyeDirection = vec4(gl_Position.xy, 1.0f, 1.0f);
		EyeDirection = gbufferProjectionInverse * EyeDirection;
		EyeDirection /= EyeDirection.w;
		EyeDirection = gbufferModelViewInverse * EyeDirection;
		EyeDirectionVector = EyeDirection.xyz;
}
