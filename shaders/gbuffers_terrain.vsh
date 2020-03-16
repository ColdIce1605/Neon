#version 420 compatibility
#define gbuffers_textured
#define vsh
#include "/lib/Syntax.glsl"

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;

attribute vec4 at_tangent;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 color;

out mat3 tbnMatrix;

#define transMAD(mat, v) (     mat3(mat) * (v) + (mat)[3].xyz)

mat3 CalculateTBN(vec3 worldPosition) {
    vec3 tangent  = normalize(at_tangent.xyz);
    vec3 binormal = normalize(-cross(gl_Normal, at_tangent.xyz));
    
    tangent  = mat3(gbufferModelViewInverse) * gl_NormalMatrix * normalize( tangent);
    binormal = mat3(gbufferModelViewInverse) * gl_NormalMatrix * normalize(binormal);
    
    vec3 normal = normalize(cross(-tangent, binormal));
    
    return mat3(gbufferModelView) * mat3(tangent, binormal, normal);
}

vec3 GetWorldSpacePosition() {
    vec3 position = transMAD(gl_ModelViewMatrix, gl_Vertex.xyz);
    
    return mat3(gbufferModelViewInverse) * position;
}

void main() {
    texcoord = gl_MultiTexCoord0.st;
    color = gl_Color;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vec3 worldPosition = GetWorldSpacePosition();
    tbnMatrix = CalculateTBN(worldPosition);

	gl_Position	= ftransform();
}