#ifdef GL_ES
precision mediump float;
#endif

varying vec3 var_color;

void main() {
    // Gamma correcting the linear interpolation of vertex colour is probably
    // overkill.
	gl_FragColor = vec4(pow(var_color, vec3(1.0 / 2.2)), 1.0);
}