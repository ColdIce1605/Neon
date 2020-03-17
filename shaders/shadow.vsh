#version 420 compatibility
#define shadow
#define vsh
#include "/lib/Syntax.glsl"

#define SHADOWMAP_BIAS 0.85


in vec4 mc_Entity;

out vec4 texcoord;
out vec4 color;

out float isTransparent;

float getIsTransparent(in float materialId) {
    if(materialId == 160.0) {
        return 1.0;
    }
    if(materialId == 95.0) {
        return 1.0;
    }
    if(materialId == 79.0) {
        return 1.0;
    }
    if(materialId == 8.0) {
        return 1.0;
    }
    if(materialId == 9.0) {
        return 1.0;
    }
    return 0.0;
}

vec4 getDistortFactor(in vec4 shadowPos) {
    vec4 multipliedPos = shadowPos * shadowPos;
    
    float factordistance = pow(multipliedPos.x * multipliedPos.x + multipliedPos.y * multipliedPos.y, 1.0 / 5.0);
    float distortFactor = (1.0 - SHADOWMAP_BIAS) + factordistance * SHADOWMAP_BIAS;
    shadowPos.xy /= distortFactor;

    return shadowPos;
}

void main() {
    gl_Position = getDistortFactor(ftransform());
    texcoord = gl_MultiTexCoord0;
    color = gl_Color;

    isTransparent = getIsTransparent(mc_Entity.x);
}