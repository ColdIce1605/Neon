#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

#define COMPOSITE 5

const bool colortex4MipmapEnabled = true;

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:4 */

layout (location = 0) out vec4 composite;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;
in blank EyeDirectionVector;

//--// Uniforms //---------------------------------------------------------------------------------------//


uniform sampler2D colortex4;

uniform float viewWidth;
uniform float viewHeight;

uniform vec3 cameraPosition;


//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/debug.glsl"

#include "/lib/preprocess.glsl"
#include "/lib/lightingConstants.glsl"

#include "/lib/util/packing/normal.glsl"
#include "/lib/util/maxof.glsl"
#include "/lib/util/noise.glsl"

//--//

vec3 rayMarch2Dclouds() {
vec2 screenres = vec2(viewWidth * viewHeight, 1.0);
vec2 p0 = fragCoord.xy / screenres.xy;
float q = fbm(p0 * cloudscale *0.5);

return 1.0;
}

void main() {

}
