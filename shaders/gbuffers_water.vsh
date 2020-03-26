#version 420 compatibility
#define gbuffers_water
#define vsh
#include "/lib/Syntax.glsl"

in vec4 mc_Enity;

uniform mat4 gbufferModelViewInverse;

uniform int worldTime;

out vec2 lmcoord;
out vec2 texcoord;

out vec3 normal;

out vec4 position;
out vec4 color;

#define DRAG_MULT 0.048
#define ITERATIONS_NORMAL 48
#define WATER_DEPTH 2.1
#define Time (worldTime / 1.0)

// returns vec2 with wave height in X and its derivative in Y
vec2 wavedx(vec2 position, vec2 direction, float speed, float frequency, float timeshift) {
	float x = dot(direction, position) * frequency + timeshift * speed;
	float wave = exp(sin(x) - 1.0);
	float dx = wave * cos(x);
	return vec2(wave, -dx);
}
float getwaves(vec2 position, int iterations) {
	float iter = 0.0;
	float phase = 6.0;
	float speed = 2.0;
	float weight = 1.0;
	float w = 0.0;
	float ws = 0.0;
    for(int i=0;i<iterations;i++){
        vec2 p = vec2(sin(iter), cos(iter));
        vec2 res = wavedx(position, p, speed, phase, Time);
        position += normalize(p) * res.y * weight * DRAG_MULT;
        w += res.x * weight;
        iter += 12.0;
        ws += weight;
        weight = mix(weight, 0.0, 0.2);
        phase *= 1.18;
        speed *= 1.07;
    }
    return w / ws;
}

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
	normal = normalize(gl_NormalMatrix * gl_Normal);
	color = gl_Color;
}