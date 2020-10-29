//--// Settings

#define VOXELIZATION_PASS

//--// Uniforms

uniform vec3 cameraPosition;

uniform mat4 shadowModelViewInverse;

uniform sampler2D tex;

#if   STAGE == STAGE_VERTEX
	//--// Vertex Inputs

	#define attribute in
	attribute vec4 mc_Entity;
	attribute vec2 mc_midTexCoord;

	//--// Vertex Outputs

	out vec4 tint;
	out vec3 scenePosition;
	out vec3 worldNormal;
	out vec2 texCoord;
	out vec2 midCoord;
	out int blockId;
	out int blockDataValue;
	out float isNotOpaque;

	//--// Vertex Functions

	void main() {
		gl_Position = gl_ModelViewMatrix * gl_Vertex;

		tint = gl_Color;
		scenePosition = (shadowModelViewInverse * gl_Position).xyz;
		worldNormal = normalize(mat3(shadowModelViewInverse) * gl_NormalMatrix * gl_Normal);
		texCoord = gl_MultiTexCoord0.st;
		midCoord = mc_midTexCoord;
		blockId = int(mc_Entity.x);
		blockDataValue = int(mc_Entity.z);

		isNotOpaque = 0.0;
		if(mc_Entity.x ==   0.0 // Something that definitely is not a block
		|| mc_Entity.x ==   6.0 // Saplings
		|| mc_Entity.x ==  26.0 // Bed
		|| mc_Entity.x ==  27.0 // Powered Rail
		|| mc_Entity.x ==  28.0 // Detector Rail
		|| mc_Entity.x ==  30.0 // Cobweb
		|| mc_Entity.x ==  31.0 // Shrub (old dead bush), Grass, Fern
		|| mc_Entity.x ==  32.0 // Dead Bush
		|| mc_Entity.x ==  37.0 // Dandelion
		|| mc_Entity.x ==  38.0 // Most small flowers
		|| mc_Entity.x ==  39.0 // Brown Mushroom
		|| mc_Entity.x ==  40.0 // Red Mushroom
		|| mc_Entity.x ==  50.0 // Torch
		|| mc_Entity.x ==  55.0 // Redstone Dust
		|| mc_Entity.x ==  59.0 // Wheat
		|| mc_Entity.x ==  63.0 // Standing Sign
		|| mc_Entity.x ==  65.0 // Ladder
		|| mc_Entity.x ==  66.0 // Rail
		|| mc_Entity.x ==  68.0 // Wall Sign
		|| mc_Entity.x ==  69.0 // Lever
		|| mc_Entity.x ==  76.0 // Redstone Torch
		|| mc_Entity.x ==  83.0 // Sugar Canes
		|| mc_Entity.x ==  90.0 // Nether Portal
		|| mc_Entity.x ==  93.0 // Redstone Repeater (Inactive)
		|| mc_Entity.x ==  94.0 // Redstone Repeater (Active)
		|| mc_Entity.x == 101.0 // Iron Bars
		|| mc_Entity.x == 102.0 // Glass Pane
		|| mc_Entity.x == 106.0 // Vines
		|| mc_Entity.x == 107.0 // Oak Fence Gate
		|| mc_Entity.x == 111.0 // Lily Pad
		|| mc_Entity.x == 116.0 // Enchantment Table
		|| mc_Entity.x == 120.0 // End Portal
		|| mc_Entity.x == 122.0 // Dragon Egg
		|| mc_Entity.x == 131.0 // Tripwire Hook
		|| mc_Entity.x == 132.0 // String
		|| mc_Entity.x == 140.0 // Flower Pot
		|| mc_Entity.x == 141.0 // Carrots
		|| mc_Entity.x == 142.0 // Potatoes
		|| mc_Entity.x == 144.0 // Mob Heads
		|| mc_Entity.x == 149.0 // Comparator (Inactive)
		|| mc_Entity.x == 150.0 // Comparator (Active)
		|| mc_Entity.x == 154.0 // Hopper
		|| mc_Entity.x == 157.0 // Activator Rail
		|| mc_Entity.x == 160.0 // Stained Glass Pane
		|| mc_Entity.x == 175.0 // Double plants (two block tall plants)
		|| mc_Entity.x == 176.0 // Standing Banner
		|| mc_Entity.x == 177.0 // Wall Banner
		|| mc_Entity.x == 183.0 // Spruce Fence Gate
		|| mc_Entity.x == 184.0 // Birch Fence Gate
		|| mc_Entity.x == 185.0 // Jungle Fence Gate
		|| mc_Entity.x == 186.0 // Dark Oak Fence Gate
		|| mc_Entity.x == 187.0 // Acacia Fence Gate
		|| mc_Entity.x == 198.0 // End Rod
		|| mc_Entity.x == 207.0 // Beetroots
		) isNotOpaque = 1.0;
	}
#elif STAGE == STAGE_GEOMETRY
	//--// Geometry Inputs

	layout (triangles) in;

	in vec4[3] tint;
	in vec3[3] scenePosition;
	in vec3[3] worldNormal;
	in vec2[3] texCoord;
	in vec2[3] midCoord;
	in int[3] blockId;
	in int[3] blockDataValue;
	in float[3] isNotOpaque;

	//--// Geometry Outputs

	layout (triangle_strip, max_vertices = 4) out;

	out vec4 fData0;
	out vec4 fData1;

	//--// Geometry Libraries

	#include "/lib/utility.glsl"
	#include "/lib/utility/packing.glsl"

	#include "/lib/shared/voxelization.glsl"

	//--// Geometry Functionss

	void main() {
		if (isNotOpaque[0] > 0.5) return;

		vec3 triCentroid = (scenePosition[0] + scenePosition[1] + scenePosition[2]) / 3.0;

		// voxel position in the 2d map
		vec3 voxelSpacePosition = sceneSpaceToVoxelSpace(triCentroid - worldNormal[0] / 32.0);
		ivec3 voxelIndex = ivec3(floor(voxelSpacePosition));
		vec4 p2d = vec4(((getVoxelStoragePos(voxelIndex) + 0.5) / float(shadowMapResolution)) * 2.0 - 1.0, worldNormal[0].y * -0.25 + 0.5, 1.0);

		float id        = blockId[0];
		float dataValue = blockDataValue[0];

		ivec2 atlasResolution = textureSize(tex, 0);
		vec2 atlasAspectCorrect = vec2(1.0, float(atlasResolution.x) / float(atlasResolution.y));
		float tileSize   = maxof(abs(texCoord[0] - midCoord[0]) / atlasAspectCorrect) / maxof(abs(scenePosition[0] - scenePosition[1]));
		vec2  tileOffset = round((midCoord[0] - tileSize * atlasAspectCorrect) * atlasResolution);
		      tileSize   = round(2.0 * tileSize * atlasResolution.x);
		      tileOffset = round(tileOffset / tileSize);

		// fill out data
		vec4 data0 = vec4(textureLod(tex, texCoord[0], 5.0).rgb, 1.0 - (id / 255.0));
		vec4 data1 = clamp(vec4(0.0 /* unused */, pack2x4(clamp(vec2(dataValue, log2(tileSize)) / 15.0, 0.0, 1.0)), tileOffset / 255.0), 0.0, 1.0);

		// Create the primitive
		const vec2[4] offs = vec2[4](vec2(-1,1),vec2(1,1),vec2(1,-1),vec2(-1,-1));
		for (int i = 0; i < 4; ++i) {
			gl_Position = p2d; fData0 = data0; fData1 = data1;
			gl_Position.xy += offs[i] / shadowMapResolution;
			EmitVertex();
		} EndPrimitive();
	}
#elif STAGE == STAGE_FRAGMENT
	//--// Fragment Inputs

	in vec4 fData0;
	in vec4 fData1;

	//--// Fragment Functionss

	void main() {
		gl_FragData[0] = fData0;
		gl_FragData[1] = fData1;
	}
#endif
