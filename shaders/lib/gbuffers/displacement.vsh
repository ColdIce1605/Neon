void calculateWavingPlants(inout vec3 position, bool doublePlant) {
	bool topVert = vertexUV.y < quadMidUV.y;
	bool topHalf = vertexMetadata.z > 8 && doublePlant;

	if (!topHalf && !topVert) return;

	vec2 disp = vec2(0.0);
	vec2 pos = (position.xz + globalTime * 1.28) / textureSize(noisetex, 0);

	// Main wind
	disp  = textureBicubic(noisetex, (pos / 16.0) + (globalTime * 0.01)).rg - 0.5;
	disp *= 0.5 + 0.3 * rainStrength;

	// Small-scale turbulence
	const uint oct = 4;
	float ampl = 0.1 + 0.15 * rainStrength;
	float gain = 0.5 + 0.2 * rainStrength;
	float freq = 1.0;
	float lacu = 1.5;

	for (uint i = 0; i < oct; i++) {
		disp += ampl * (textureSmooth(noisetex, pos * freq).rg - 0.5);
		ampl *= gain;
		freq *= lacu;
		pos  *= mat2(cos(1), sin(1), -sin(1), cos(1));
	}

	// Scale down in caves and similar
	disp *= vertexLightmap.y / 240.0;

	// Displace within a circle, not a square.
	disp *= normalize(abs(disp));

	if (doublePlant) disp *= mix(0.5, 2.0, topHalf && topVert);

	position.xz += sin(disp);
	position.y  += cos((disp.x + disp.y) * mix(1.0, 0.5, topHalf && topVert)) - 1.0;
}

vec3 get3DNoiseTexture(vec3 coord) {
	coord.xy /= textureSize(noisetex, 0);

	coord.x += floor(coord.z) * 0.05 * PI;

	vec3 noisel = textureSmooth(noisetex, coord.xy).rgb;
	vec3 noiseh = textureSmooth(noisetex, (coord.xy + vec2(0.05, 0.0) * PI)).rgb;

	float mixf = smoothstep(floor(coord.z), ceil(coord.z), coord.z);

	return mix(noisel, noiseh, mixf);
}

void calculateWavingLeaves(inout vec3 position) {
	vec3 disp = vec3(0.0);
	vec3 pos = position.xzy;
	pos += globalTime * vec3(0.9, 0.9, 0.3);

	const uint oct = 3;
	float gain = 0.4 + rainStrength * 0.1;
	const float lacu = 1.6;
	float ampl = 0.1 + rainStrength * 0.02;
	float freq = 0.7;

	for (uint i = 0; i < oct; i++) {
		disp += ampl * (get3DNoiseTexture(pos * freq) - 0.5);
		ampl *= gain;
		freq *= lacu;
		pos.xy *= mat2(cos(1), sin(1), -sin(1), cos(1));
	}

	// Scale down in caves and similar
	disp *= vertexLightmap.y / 240.0;

	// Displace within a sphere, not a cube.
	disp *= normalize(abs(disp));

	position += disp.xzy;
}

void calculateDisplacement(inout vec3 position) {
	if (vertexLightmap.y == 0.0) return;

	switch (int(vertexMetadata.x)) {
		case 31:  // Tall grass and fern
		case 37:  // Flowers
		case 59:  // Crops
			calculateWavingPlants(position, false); break;
		case 175: // Double plants
			calculateWavingPlants(position, true); break;
		case 18:  // Leaves
		case 106: // Vines (look better when treated as leaves here)
			calculateWavingLeaves(position); break;
		default: break;
	}
}
