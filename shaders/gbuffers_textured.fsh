#version 120

uniform sampler2D texture;

varying vec4 color;
varying vec2 uv;

void main() {
    gl_FragData[0] = color * texture2D( texture, uv );
    gl_FragData[5] = vec4(1.0, 0.0, 0.0, 1.0);
    gl_FragData[6] = vec4(0.0, 0.0, 0.0, 0.0);
    gl_FragData[7] = vec4(0.5, 0.5, 1.0, 1.0);
}
