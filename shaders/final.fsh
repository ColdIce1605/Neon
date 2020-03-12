#version 420 compatibility
#define final
#define fsh
#include "/lib/Syntax.glsl"

#define Saturation 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define Vibrance 1.5 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define Vignette_Strength 1.6 //[0.0 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5]

uniform sampler2D colortex0;

in vec2 texcoord;
in vec4 color;

vec3 getTonemap(in vec3 color) {  
  color = pow(color, vec3(1.0/1.1)); //Gamma Correction
  
  float getrgb = (color.r + color.g + color.b) / 3.2; //mixes rgb divided to make it less saturated 
  float weight = Saturation + (1.0 - getrgb) * (0.1 + (Vibrance - 1.0));
  
  return mix(vec3(getrgb), color, weight * 1.2); 
}

vec3 vignette(vec3 color) {
    float dist = distance(texcoord.st, vec2(0.5)) * Vignette_Strength;

    dist = pow(dist/2.0, 1.1);

    return color * (1.0 - dist);
}

void main() {

    vec4 color = texture2D(colortex0, texcoord.st) * color;
    color.rgb = getTonemap(color.rgb);

    color.rgb = vignette(color.rgb);

    /*DRAWBUFFERS:0*/
    gl_FragData[0] = color;
}