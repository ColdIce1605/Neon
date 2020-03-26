#version 420 compatibility

  #extension GL_EXT_gpu_shader4 : require
  #extension GL_ARB_shader_texture_lod : enable

#define composite4
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/framebuffer.glsl"
#include "/lib/Settings.glsl"

/* DRAWBUFFERS:02 */

uniform sampler2D tex;
uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;

uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

in vec2 texcoord;
in vec2 screenCoord;

layout (location = 0) out vec4 albedo;
/*
uniform bool horizontal;
uniform float weight[5] = float[] (0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

//layout (location = 0) out vec4 albedo;
//layout (location = 3) out vec4 bloom_pass1;

void bloom() {
float brightness = dot(colortex0.rgb, vec3(0.2126, 0.7152, 0.0722));
    if(brightness > 1.0)
        BrightColor = vec4(colortex0.rgb, 1.0);
    else
        BrightColor = vec4(0.0, 0.0, 0.0, 1.0);
}
*/
void main() {
    vec3 color = texture2D(colortex0, texcoord.st).rgb;
    albedo = vec4(color, 1.0);

    //bloom_pass1 = vec4(bloom(), 1.0);
}