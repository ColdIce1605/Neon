#version 420 compatibility

  #extension GL_EXT_gpu_shader4 : require
  #extension GL_ARB_shader_texture_lod : enable

#define composite5
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

/* DRAWBUFFERS:0 */

uniform sampler2D colortex0;
uniform sampler2D colortex2;

uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;
in vec2 screenCoord;

in vec4 timeVector;

layout (location = 0) out vec4 albedo;

vec3 getBloomTile(in vec2 screenCoord, cin(int) lod, cin(vec2) offset) {
      #ifndef BLOOM
        return vec3(0.0);
      #endif

      const float tilePower = 1.0 / 128.0;

      float a = 1.0 / pow(2.0, float(lod));
      float b = pow(9.0 - float(lod), tilePower);

      vec2 halfPixel = rcp(vec2(viewWidth, viewHeight)) * 0.5;

      return colortex2, (screenCoord - halfPixel * a + offset) * b;
    }

      float luma(vec3 color) {
	return dot(color, vec3(0.2126, 0.7152, 0.0722));
      }

    vec3 drawBloom(in vec3 color, in vec2 screenCoord) {
      #ifndef BLOOM
        return color;
      #endif

      vec3 bloom = vec3(0.0);
      float screenLuma = 0.0;
      screenLuma = max(0.0, 0.7 / screenLuma + mix(1.0, 0.01, timeNight));
      screenLuma = pow(screenLuma, 3.0);

      bloom += getBloomTile(screenCoord, 2, vec2(0.0, 0.0));
      bloom += getBloomTile(screenCoord, 3, vec2(0.3, 0.0));
      bloom += getBloomTile(screenCoord, 4, vec2(0.0, 0.3));
      bloom += getBloomTile(screenCoord, 5, vec2(0.1, 0.3));
      bloom += getBloomTile(screenCoord, 6, vec2(0.2, 0.3));
      bloom += getBloomTile(screenCoord, 7, vec2(0.3, 0.3));
      bloom *= min(300.0, screenLuma) * luma(bloom) * 10.0;

      return mix(color, bloom, 0.02);
    }

void main() {
    vec3 color = texture2D(colortex0, texcoord.st).rgb;
    color.rgb += drawBloom(color, screenCoord);
    color = color / (1.0 + color);
    albedo = vec4(color, 1.0);
    
}