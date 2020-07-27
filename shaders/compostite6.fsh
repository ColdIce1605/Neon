#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

#define FINAL

#include "/cfg/bloom.scfg"

const bool colortex4MipmapEnabled = true;

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:06 */

layout (location = 0) out vec3 composite;
layout (location = 1) out vec4 temporalBuffer;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;

in float avglum;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform sampler2D colortex4;
uniform sampler2D colortex6;

uniform float blindness;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/debug.glsl"

#include "/lib/preprocess.glsl"

//--//

void lowLightAdapt(inout vec3 color) { 
	const float maxLumaRange = 2.5;
	const float minLumaRange = 0.00001;
  float rod = dot(color, vec3(15, 50, 35)); 
  rod *= 1.0 - pow(smoothstep(0.0, 4.0, rod), 0.01); 

  color = (rod + color) * clamp(0.3 / avglum, minLumaRange, maxLumaRange); 
}

void main() {
	composite = texture(colortex4, fragCoord).rgb;
	temporalBuffer = vec4(0.0, 0.0, 0.0, avglum);

	lowLightAdapt(finalColor);


	debugExit();
}
