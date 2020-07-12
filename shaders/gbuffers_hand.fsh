#version 420 compatibility

//--// Outputs //----------------------------------------------------------------------------------------//



layout (location = 0) out vec4 albedo/;
layout (location = 2) out vec4 normal_basic;

//--// Inputs //-----------------------------------------------------------------------------------------//

uniform sampler2D colortex0;

in vec4 color;
in vec4 texcoord;

in vec3 normal;

//--// Functions //--------------------------------------------------------------------------------------//

void main() {
    albedo = texture2D(colortex0, texcoord.st) * color;
    normal_basic = vec4(normal * 0.5 + 0.5, 1.0);
}