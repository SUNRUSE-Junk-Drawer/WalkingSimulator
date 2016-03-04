#ifdef GL_ES
precision mediump float;
#endif

varying vec2 var_uv;
varying vec3 var_color;
uniform sampler2D brushstrokes;

void main() {
    if(texture2D(brushstrokes, var_uv).r < length(var_uv)) discard;
	gl_FragColor = vec4(var_color, 1.0);
}