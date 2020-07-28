#version 420 compatibility

out vec4 color;
out vec2 uv;

void main() {
    color = gl_Color;
    uv = gl_MultiTexCoord0.st;

    gl_Position = ftransform();
}
