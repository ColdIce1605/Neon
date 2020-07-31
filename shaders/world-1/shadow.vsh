#version 420 compatibility

//--// Outputs //----------------------------------------------------------------------------------------//

out vec4 tint;
out vec2 baseUV;
out vec3 vertNormal;

out float isTransparent;

//--// Inputs //-----------------------------------------------------------------------------------------//

layout (location = 0)  in vec4 vertexPosition;
layout (location = 2)  in vec3 vertexNormal;
layout (location = 3)  in vec4 vertexColor;
layout (location = 8)  in vec2 vertexUV;
layout (location = 9)  in vec2 vertexLightmap;
layout (location = 10) in vec4 vertexMetadata;
layout (location = 11) in vec2 quadMidUV;

in vec4 mc_Entity;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform int entityId;

uniform float rainStrength;

uniform vec3 cameraPosition;

uniform mat4 shadowModelView, shadowProjection;
uniform mat4 shadowModelViewInverse;

uniform sampler2D noisetex;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/preprocess.glsl"
#include "/lib/time.glsl"

#include "/lib/util/textureBicubic.glsl"
#include "/lib/util/textureSmooth.glsl"

//--//

#include "/lib/gbuffers/initPosition.vsh"

//--//

#include "/lib/gbuffers/displacement.vsh"

//--//

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
    if(entityId == 2000) {
        return 1.0;
    }
    return 0.0;
}

void main() {
	//if (abs(vertexMetadata.x - 8.5) < 0.6) {
	//	gl_Position = vec4(1.0);
	//	return;
	//} //no idea just know it causes problems

	gl_Position = initPosition();
	gl_Position = shadowModelViewInverse * gl_Position;

	gl_Position.xyz += cameraPosition;
	calculateDisplacement(gl_Position.xyz);
	gl_Position.xyz -= cameraPosition;

	gl_Position = shadowProjection * shadowModelView  * gl_Position;

	gl_Position.xyz /= vec3(vec2(1.0 + length(gl_Position.xy)), 4.0);

	tint   = vertexColor;
	baseUV = vertexUV;
	vertNormal = gl_NormalMatrix * vertexNormal;
}
