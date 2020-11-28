//--// Settings

#include "/internalSettings.glsl"

//--// Uniforms

uniform float viewWidth, viewHeight;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

//
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex3;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

// Propagation volume
uniform sampler2D colortex4;

//--// Shared Libraries

//--// Shared Functions

#if STAGE == STAGE_VERTEX
	//--// Vertex Outputs

	out vec2 screenCoord;

	//--// Vertex Functions

	void main() {
		screenCoord    = gl_Vertex.xy;
		gl_Position.xy = gl_Vertex.xy * 2.0 - 1.0;
		gl_Position.zw = vec2(1.0);
	}
#elif STAGE == STAGE_FRAGMENT
	//--// Fragment Inputs

	in vec2 screenCoord;

	//--// Fragment Outputs

	/* DRAWBUFFERS:2 */

	layout (location = 0) out vec3 color;

	//--// Fragment Libraries

	#include "/lib/utility.glsl"
	#include "/lib/utility/colorspace.glsl"
	#include "/lib/utility/dithering.glsl"
	#include "/lib/utility/encoding.glsl"
	#include "/lib/utility/packing.glsl"
	#include "/lib/utility/spaceConversion.glsl"
	#include "/lib/utility/sphericalHarmonics.glsl"

	//--// Fragment Functions



	void main() {
        vec4 depth = texture2D(depthtex0, screenCoord);
        vec4 gbufferTextureInfo = texture(colortex0, screenCoord);
        vec4 gbufferNormalId    = texture(colortex1, screenCoord);

        vec3 albedo = vec3(unpack2x8(gbufferTextureInfo.r), unpack2x8X(gbufferTextureInfo.g));
            albedo = srgbToLinear(albedo);
        vec3 normal = decodeNormal(gbufferNormalId.rg * 2.0 - 1.0);

        mat3 position;
        position[0] = vec3(screenCoord, texture(depthtex1, screenCoord).r);
        position[1] = screenSpaceToViewSpace(position[0], gbufferProjectionInverse);
        position[2] = mat3(gbufferModelViewInverse) * position[1] + gbufferModelViewInverse[3].xyz;

        if (depth.r < 1.0) {
            color  = albedo;
		}
    }
#endif
