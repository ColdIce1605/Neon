#version 420 compatibility
#define shadow
#define fsh
#include "/lib/Syntax.glsl"
#include "/lib/framebuffer.glsl"
#include "/lib/Settings.glsl"

uniform sampler2D tex;
uniform sampler2D texture;

in vec4 texcoord;
in vec4 color;
in float isTransparent;

void main() {
    if (texture2D(texture, texcoord.st).a < 0.35) {
        discard;
    }
    vec3 fragColor = color.rgb * texture2D(tex, texcoord.st).rgb;
    fragColor = mix(vec3(0), fragColor, isTransparent);

    gl_FragData[0] = vec4(fragColor, 1.0);
}