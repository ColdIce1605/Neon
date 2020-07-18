vec4 initPosition() {
	return gl_ModelViewMatrix * vertexPosition;
}
