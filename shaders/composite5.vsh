#version 420

//--// Outputs //----------------------------------------------------------------------------------------//

out vec2 fragCoord;

//--// Inputs //-----------------------------------------------------------------------------------------//

layout (location = 0) in vec4 vertexPosition;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
	gl_Position = vertexPosition * 2.0 - 1.0;
	fragCoord = vertexPosition.xy;
}
