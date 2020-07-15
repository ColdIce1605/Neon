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

uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;

uniform vec3 cameraPosition;
uniform vec3 sunPosition;


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
float q = fbm(p0 * cloudscale * 0.5);
    
     
    float t = (frameCounter + 45.0) * speed;
    vec2 time = vec2(q + t * 1.0, q + t * 0.25);
	
    vec2 dist = (vec2(16.) / screenres);
    const int steps = 8;
    float steps_inv = 1.0 / float(steps);
    
    vec2 sun_dir = ((sunPosition) * 2. - 1.);
    
    vec2 dp = normalize(sun_dir) * dist * steps_inv;
    
    float T = 0.0;
    
    vec2 p = p0;
    float dens0 = density(p, aspect, time);
    float A = dens0;
    
    for(int i = 0; i < steps; ++i)
    {
        float h = float(i) * steps_inv;
        p +=  dp * (1. + h * (hash(p) * 0.75)); // increase step size for each step
        
   		float dens = density(p, aspect, time);
        T += (clamp((dens0 - dens), 0.0, 1.0) + ambient * steps_inv) * (1. - h);
    }
    
    T = clamp(T, 0.0, 1.0);
    vec3 C = vec3(0.0);
    C = vec3(T) * intensity;
    C = vec3(1.) - (vec3(1.) - C) * (vec3(1.) - skycolour * 0.5);

return C;
}

void main() {

}
