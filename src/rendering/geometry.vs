#ifdef GL_ES
precision mediump float;
#endif

attribute vec3 location;
attribute vec3 color;

uniform vec2 postScale;
varying vec3 var_color;

uniform mat4 transform;

void main() {
    // Gamma correcting the linear interpolation of vertex colour is probably
    // overkill.
	var_color = pow(color, vec3(2.2));
    vec3 transformed = (vec4(location, 1.0) * transform).xyz;
	gl_Position = vec4(transformed.xy * postScale, -1.0, transformed.z);
}