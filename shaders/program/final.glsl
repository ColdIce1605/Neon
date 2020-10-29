//--// Settings

#include "/settings.glsl"

const bool colortex2MipmapEnabled = true;

//--// Uniforms

uniform float viewWidth;

uniform sampler2D colortex2;

#if   STAGE == STAGE_VERTEX
	//--// Vertex Outputs

	out vec2 screenCoord;

	//--// Vertex Functions

	void main() {
		screenCoord    = gl_Vertex.xy;
		gl_Position.xy = gl_Vertex.xy * 2.0 - 1.0;
		gl_Position.zw = vec2(1.0);
	}
#elif STAGE == STAGE_FRAGMENT
	//--// Fragment Inputs

	in vec2 screenCoord;

	//--// Fragment Outputs

	layout (location = 0) out vec3 color;

	//--// Fragment Libraries

	#include "/lib/utility.glsl"
	#include "/lib/utility/colorspace.glsl"
	#include "/lib/utility/dithering.glsl"

	#include "/lib/fragment/filmTonemap.fsh"

	#include "/lib/shared/celestialConstants.glsl"

	//--// Fragment Functions

	void main() {
		color  = texture(colortex2, screenCoord).rgb;
		color  = tonemap(color);
		color  = linearToSrgb(color);
		

		color += (bayer4(gl_FragCoord.st) + 0.5/16.0) / (exp2(8.0) - 1.0);
	}
#endif
