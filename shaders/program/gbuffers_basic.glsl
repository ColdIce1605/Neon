//--// Settings

#include "/settings.glsl"

//--// Uniforms

uniform int frameCounter;

uniform mat4 gbufferModelViewInverse;

uniform sampler2D tex;
uniform sampler2D specular;

uniform vec2 viewPixelSize;

#if   STAGE == STAGE_VERTEX
	//--// Vertex Inputs

	#define attribute in
	attribute vec3 mc_Entity;

	//--// Vertex Outputs

	out vec4 tint;
	out vec2 textureCoordinates;
	flat out vec3 normal;
	flat out int id;

	//--// Vertex Libraries

	//--// Vertex Functions

	void main() {
		gl_Position = ftransform();
		tint = gl_Color;
		textureCoordinates = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
		normal = normalize(mat3(gbufferModelViewInverse) * gl_NormalMatrix * gl_Normal);
		id = max(int(mc_Entity.x), 1);
	}
#elif STAGE == STAGE_FRAGMENT
	//--// Fragment Inputs

	in vec4 tint;
	in vec2 textureCoordinates;
	flat in vec3 normal;
	flat in int id;

	//--// Fragment Outputs

	/* DRAWBUFFERS:01 */

	layout (location = 0) out vec4 outTexture;
	layout (location = 1) out vec4 outNormalId;

	//--// Fragment Libraries

	#include "/lib/utility/encoding.glsl"
	#include "/lib/utility/packing.glsl"

	//--// Fragment Functionss

	void main() {
		vec4 baseTex = textureLod(tex, textureCoordinates, 0.0) * tint;
		if (baseTex.a < 0.102) discard;
		vec4 specTex = textureLod(specular, textureCoordinates, 0.0);

		outTexture  = vec4(pack2x8(baseTex.rg), pack2x8(baseTex.ba), pack2x8(specTex.rg), pack2x8(specTex.ba));
		outNormalId = vec4(encodeNormal(normal) * 0.5 + 0.5, id / 65535.0, 1.0);
	}
#endif
