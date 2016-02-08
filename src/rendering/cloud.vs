#ifdef GL_ES
precision mediump float;
#endif

attribute vec3 origin;
attribute vec2 local;
attribute vec3 color;
uniform mat4 newTransform;
uniform mat4 oldTransform;
uniform vec2 postScale;
varying vec2 var_uv;
varying vec3 var_color;

vec3 applyTransform(mat4 transform) {
	return (vec4(origin, 1.0) * transform).xyz;
}

void main() {
	var_color = color;

	vec3 oldOrigin = applyTransform(oldTransform);
	vec3 newOrigin = applyTransform(newTransform);
	vec2 originDifference = (newOrigin.xy / newOrigin.z) - (oldOrigin.xy / oldOrigin.z);
	// If the computed start/end of the splat are in the exact same location, the normal between them is undefined.
	// This happens reasonably frequently.
	var_uv = sign(local);
	if(originDifference == vec2(0.0)) {
		gl_Position = vec4((newOrigin.xy + local) * postScale, -1.0, newOrigin.z);
	} else {
		originDifference = normalize(originDifference);
        mat2 subTransform = mat2(-originDifference.x, -originDifference.y, originDifference.y, -originDifference.x);
        vec2 uv = var_uv * 0.5 + 0.5;
		gl_Position = vec4((mix(newOrigin.xy, oldOrigin.xy, uv.y) + local * subTransform) * postScale, -1.0, mix(newOrigin.z, oldOrigin.z, uv.y));
        var_uv = var_uv * subTransform;
	}
}