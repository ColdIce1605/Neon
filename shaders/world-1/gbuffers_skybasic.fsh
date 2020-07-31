#version 420

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:4 */

layout (location = 0) out vec4 stars;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/lightingConstants.glsl"

void main() {
	stars.rgb = vec3(1.0) * LUMINANCE_STARS;
	stars.a = 1.0;
}
