#version 120

varying vec4 color;
varying vec2 uv;

void main() {
    color = gl_Color;
    uv = gl_MultiTexCoord0.st;

    gl_Position = ftransform();
}
