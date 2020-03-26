#version 420 compatibility

  #extension GL_EXT_gpu_shader4 : require
  #extension GL_ARB_shader_texture_lod : enable

#define composite5
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/framebuffer.glsl"
#include "/lib/Settings.glsl"

/* DRAWBUFFERS:0 */

uniform sampler2D colortex0;
uniform sampler2D colortex3;

uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;
in vec2 screenCoord;

layout (location = 0) out vec4 albedo;

void main() {
    vec3 color = texture2D(colortex0, texcoord.st).rgb;
    albedo = vec4(color, 1.0);
    
}