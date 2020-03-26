#version 420 compatibility
#define composite1
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/framebuffer.glsl"
#include "/lib/Settings.glsl"

#include "/lib/poisson.glsl"

layout (location = 0) out vec4 albedo;
layout (location = 1) out vec4 depth_composite1;

#define SHADOWMAP_BIAS 0.85

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D shadowtex0; 
uniform sampler2D shadowcolor0; //only one
uniform sampler2D depthtex1; //samples depth
uniform sampler2D noisetex;  //for rotation matrix
uniform sampler2D normals;

uniform vec3 cameraPosition;
uniform vec3 shadowLightPosition;

uniform mat4 gbufferModelViewInverse; //for position
uniform mat4 gbufferModelView;
uniform mat4 shadowProjection; //shadow position
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView; // shadow model view

uniform int worldTime;

uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;

in vec4 texcoord;



float timefract = worldTime; //using another name for worldtime

//Get the time of the day
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0)); //get the time of the sunrise, noon, sunset and night
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

#include "/lib/getSpace.glsl"

vec4 getDistortFactor(in vec4 shadowPos) {
    vec4 multipliedPos = shadowPos * shadowPos;
    
    float factordistance = pow(multipliedPos.x * multipliedPos.x + multipliedPos.y * multipliedPos.y, 1.0 / 5.0);
    float distortFactor = (1.0 - SHADOWMAP_BIAS) + factordistance * SHADOWMAP_BIAS;
    shadowPos.xy /= distortFactor;

    return shadowPos;
}

vec3 getShadowSpacePosition(in vec2 coord) {
    vec4 worldSpacePos = getWorldSpacePosition(coord);
    worldSpacePos.xyz -= cameraPosition; //important for shadows
    vec4 shadowSpacePos = shadowModelView * worldSpacePos;
 shadowSpacePos = shadowProjection * shadowSpacePos;

 shadowSpacePos = getDistortFactor(shadowSpacePos);

    return shadowSpacePos.xyz * 0.5 + 0.5;
}

mat2 getRotationMatrix(in vec2 coord) {
    float rotationAmount = texture2D(
        noisetex,
        coord * vec2(
            viewWidth / noiseTextureResolution,
            viewHeight / noiseTextureResolution
        )
    ).r;
    
    return mat2(
        cos(rotationAmount), -sin(rotationAmount),
        sin(rotationAmount), cos(rotationAmount)
    );
}  // shadow rotation

vec3 getShadows(in vec2 coord) {
    vec3 shadowCoord = getShadowSpacePosition(coord);

    mat2 rotationMatrix = getRotationMatrix(coord);

    vec3 shadowColor = vec3(0.0); //variable

    for (int i = 0; i < samplePoints.length(); i++) { //shadows loop

        vec2 offset = vec2(samplePoints[i] / shadowMapResolution); // for rotationmatrix
        offset = rotationMatrix * offset; 
        
        float shadowMapSample = texture2D(shadowtex0, shadowCoord.st + offset).r;
        float visibility = step(shadowCoord.z - shadowMapSample, 0.001);
        
        vec3 litTimesColor = vec3(0.6, 0.6, 0.3);
        vec3 dayColor = vec3(1.0);
        vec3 nightColor = vec3(0.5);
        vec3 mixedColor = vec3(litTimesColor * TimeSunrise + dayColor * TimeNoon + litTimesColor * TimeSunset + nightColor * TimeMidnight);
        vec3 colorSample = texture2D(shadowcolor0, shadowCoord.st + offset).rgb; //for sampling shadow color
        shadowColor += mix(colorSample, mixedColor, visibility);
    }
    return vec3(shadowColor) / samplePoints.length();
} //shadows code

vec3 calculateLighting(in vec3 color) {
    vec3 sunLight = getShadows(texcoord.st);
    vec3 ambientLight = (vec3(0.75) * TimeSunrise + (vec3(0.5, 0.7, 1.0) * 0.5) * TimeNoon + vec3(0.75) * TimeSunset + vec3(0.55) * TimeMidnight);
    vec3 normalMap = texture2D(colortex2, texcoord.st).xyz * 2.0 - 1.0;

    float Diffuse = max(dot(normalMap, normalize(shadowLightPosition)), 0.0);

    sunLight *= vec3(min(Diffuse, float(sunLight)));

    return color * (sunLight + ambientLight);
} //lighting

void main() {
    depth = texture2D(depthtex1, texcoord.st).r;
    bool isTerrain = depth < 1.0; 
    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    if (isTerrain) color = calculateLighting(color);

    albedo = vec4(color, 1.0); //fragdatas are vec4s must have , 1.0 to do vec3s
    depth_composite1 = vec4(depth); //depth come out
}
