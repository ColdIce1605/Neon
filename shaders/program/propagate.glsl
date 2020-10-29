//--// Settings

//--// Uniforms

uniform float viewWidth, viewHeight;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

// Voxelized volume
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform sampler2D colortex1;
uniform sampler2D depthtex0;

// Propagation volume
uniform sampler2D colortex4;
uniform sampler2D gaux2;
uniform sampler2D gaux3;

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

	/* DRAWBUFFERS:4 */

	layout (location = 0) out vec3 volume;

	//--// Fragment Libraries

	#include "/lib/utility.glsl"
	#include "/lib/utility/colorspace.glsl"
	#include "/lib/utility/spaceConversion.glsl"
	#include "/lib/utility/sphericalHarmonics.glsl"

	#include "/lib/shared/voxelization.glsl"

	#include "/lib/fragment/lightPropagationVolume.fsh"

	//--// Fragment Functions

	ivec3 lpvSpaceToVoxelSpace(ivec3 lpvIndex) {
		lpvIndex.y += int(floor(cameraPosition.y));
		return lpvIndex;
	}

	bool getVoxelOccupancy(ivec3 voxelIndex) {
		vec4[2] voxel = readVoxelData(voxelIndex);
		return voxel[0].a > 0.0;
	}
	float getVoxelOcclusion(ivec3 voxelIndex) {
		return float(!getVoxelOccupancy(voxelIndex));
	}
	vec3 getLightEmission(ivec3 voxelIndex) {
		vec4[2] voxel = readVoxelData(voxelIndex);
		if (voxel[0].a <= 0.0) return vec3(0.0);
		int id = int(floor(voxel[0].a * 255.0 + 0.5));

		bool emissive =
		id ==  89 ||
		id == 124 ||
		id == 138 ||
		id == 169;

		return emissive ? srgbToLinear(voxel[0].rgb) : vec3(0.0);
	}

	vec3 calculateLPVPropagation(ivec3 lpvIndex) {
		vec3 propagated = vec3(0.0);

		const vec3[6] directions = vec3[6](vec3(0,0,1), vec3(0,0,-1), vec3(1,0,0), vec3(-1,0,0), vec3(0,1,0), vec3(0,-1,0));

		for (int i = 0; i < 6; ++i) {
			vec3 light = GetLight(lpvIndex + ivec3(directions[i]));

			//propagated = max(propagated, light - 1.0 / 255.0);
			propagated += light / 6.0;
		}

		return propagated;
	}


	void main() {
		ivec3 lpvIndex = lpvStoragePosToLPVIndex(ivec2(gl_FragCoord.st));
		ivec3 voxelIndex = lpvSpaceToVoxelSpace(lpvIndex);

		vec3 propagated = getVoxelOccupancy(voxelIndex) ? vec3(0.0) : calculateLPVPropagation(lpvIndex);
		vec3 emitted = getLightEmission(voxelIndex);
		

		//vec3 total = max(propagated, emitted);
		vec3 total = propagated + emitted;
		
		volume = total;
	}
#endif
