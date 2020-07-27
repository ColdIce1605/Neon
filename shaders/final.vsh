#version 420

//--// Outputs //----------------------------------------------------------------------------------------//

out vec2 fragCoord;

out float avglum;

//--// Inputs //-----------------------------------------------------------------------------------------//

layout (location = 0) in vec2 vertexPosition;
layout (location = 8) in vec2 vertexUV;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform sampler2D colortex4;

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
	gl_Position.xy = vertexPosition * 2.0 - 1.0;
	gl_Position.zw = vec2(1.0);

	fragCoord = vertexUV;

	avglum = dot(textureLod(colortex4, vec2(0.5), 10).rgb, vec3(1.0 / 3.0));
}