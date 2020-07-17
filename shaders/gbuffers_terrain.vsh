#version 420 compatibility

//--// Outputs //----------------------------------------------------------------------------------------//

out vec3 positionView;

out mat3 tbnMatrix;
out vec4 tint;
out vec2 baseUV, lmUV;
out vec4 metadata;

//--// Inputs //-----------------------------------------------------------------------------------------//

//layout (location = 0)  in vec4 vertexPosition;
layout (location = 2)  in vec3 vertexNormal;
//layout (location = 3)  in vec4 vertexColor;
layout (location = 8)  in vec2 vertexUV;
layout (location = 9)  in vec2 vertexLightmap;
layout (location = 10) in vec4 vertexMetadata;
layout (location = 11) in vec2 quadMidUV;
layout (location = 12) in vec4 vertexTangent;

//--// Uniforms //---------------------------------------------------------------------------------------//

uniform float rainStrength;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView, gbufferProjection;
uniform mat4 gbufferModelViewInverse;

uniform sampler2D noisetex;

//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/preprocess.glsl"
#include "/lib/time.glsl"

#include "/lib/util/textureBicubic.glsl"
#include "/lib/util/textureSmooth.glsl"

//--//

#include "/lib/gbuffers/initPosition.vsh"

mat3 calculateTBN() {
	vec3 tangent = normalize(vertexTangent.xyz);

	return mat3(
		gl_NormalMatrix * tangent,
		gl_NormalMatrix * cross(tangent, vertexNormal) * sign(vertexTangent.w),
		gl_NormalMatrix * vertexNormal
	);
}

//--//

#include "/lib/gbuffers/displacement.vsh"

//--//

void main() {
	gl_Position = initPosition();
	positionView = gl_Position.xyz;
	vec4 positionLocal = gbufferModelViewInverse * gl_Position;
	vec4 positionWorld = positionLocal + vec4(cameraPosition, 0.0);
	calculateDisplacement(positionWorld.xyz);
	positionLocal = positionWorld - vec4(cameraPosition, 0.0);
	gl_Position = gbufferModelView * positionLocal;
	gl_Position = gbufferProjection * gl_Position;

	tbnMatrix = calculateTBN();
	tint      = gl_Color;
	baseUV    = vertexUV;
	lmUV      = vertexLightmap / 240.0;
	metadata  = vertexMetadata;
}
