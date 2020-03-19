#version 420 compatibility

  #extension GL_EXT_gpu_shader4 : require
  #extension GL_ARB_shader_texture_lod : enable

#define composite4
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
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
layout (location = 2) out vec4 bloom_pass1;

vec3 getBloomTile(in vec2 screenCoord, cin(int) lod, cin(vec2) offset) {
 
      const int width     = 7;
      const int samples   = width * width;

      float scale = pow(2.0, lod);

      float a = pow(0.5, 0.5) * 20.0;

      vec3 tile = vec3(0.0);

      vec2 pixelSize = rcp(viewWidth) * vec2(1.0, aspectRatio);

      vec2 coord = screenCoord - offset;
      vec2 scaledCoord = coord * scale;

      if(scaledCoord.x > -0.1 && scaledCoord.y > -0.1 && scaledCoord.x < 1.1 && scaledCoord.y < 1.1) {
        vec2 sampleCoord = vec2(0.0);
        float weight = 0.0;

        for(int i = 0; i < samples; ++i) {
          sampleCoord = to2D(i, samples);

          weight = sqrt(1.0 - length(sampleCoord - vec2(3.0)) * 0.25) * a;

          if(weight <= 0.0) 
              continue;

          tile += texture2DLod(colortex0, (pixelSize * (sampleCoord - vec2(2.5, 3.0)) + coord) * scale, lod).rgb * weight;
        }
      }

      return tile;
}

vec3 computeBloomTiles(vec2 screenCoord) {

      vec3 tiles = vec3(0.0);

      tiles += getBloomTile(screenCoord, 2, vec2(0.0, 0.0));
      tiles += getBloomTile(screenCoord, 3, vec2(0.3, 0.0));
      tiles += getBloomTile(screenCoord, 4, vec2(0.0, 0.3));
      tiles += getBloomTile(screenCoord, 5, vec2(0.1, 0.3));
      tiles += getBloomTile(screenCoord, 6, vec2(0.2, 0.3));
      tiles += getBloomTile(screenCoord, 7, vec2(0.3, 0.3));

      return tiles;
}

void main() {
    vec3 color = texture2D(colortex0, texcoord.st).rgb;
    albedo = vec4(color, 1.0);

    bloom_pass1 = vec4(computeBloomTiles(screenCoord), 1.0);
}