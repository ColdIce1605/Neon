#version 420 compatibility

//--// Outputs //----------------------------------------------------------------------------------------//

out vec4 color;

//--// Inputs //-----------------------------------------------------------------------------------------//

layout (location = 0) in vec4 vertexPosition;
layout (location = 3) in vec4 vertexColor;

//--// Uniforms //---------------------------------------------------------------------------------------//

//uniform mat4 gbufferProjection;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/gbuffers/initPosition.vsh"

void main() {
	gl_Position = gl_ProjectionMatrix * initPosition();

	color = vertexColor;
}
