#ifdef GL_ES
precision mediump float;
#endif

attribute vec3 origin;
attribute vec2 local;
attribute vec3 color;

#ifdef BONES
// This should be an integer, but integer attributes appear to be impossible in WebGL.
attribute float bone;
uniform mat4 newTransform[BONES];
uniform mat4 oldTransform[BONES];
#else
uniform mat4 newTransform;
uniform mat4 oldTransform;
#endif

uniform vec2 postScale;
varying vec2 var_uv;
varying vec2 var_noiseUv;
varying vec3 var_color;

vec3 applyTransform(mat4 transform) {
	return (vec4(origin, 1.0) * transform).xyz;
}

void main() {
	var_color = color;

    #ifdef BONES
        vec3 oldOrigin = applyTransform(oldTransform[int(bone)]);
        vec3 newOrigin = applyTransform(newTransform[int(bone)]);
    #else
        vec3 oldOrigin = applyTransform(oldTransform);
        vec3 newOrigin = applyTransform(newTransform);
    #endif
	vec2 originDifference = (newOrigin.xy / newOrigin.z) - (oldOrigin.xy / oldOrigin.z);
	// If the computed start/end of the splat are in the exact same location, the normal between them is undefined.
	// This happens reasonably frequently.
	var_uv = sign(local);
	if(originDifference == vec2(0.0)) {
		gl_Position = vec4((newOrigin.xy + local) * postScale, -1.0, newOrigin.z);
	} else {
		originDifference = normalize(originDifference);
        
        mat2 subTransform = mat2(originDifference.x, originDifference.y, originDifference.y, -originDifference.x);
        vec2 uv = var_uv * 0.5 + 0.5;
		gl_Position = vec4((mix(oldOrigin.xy, newOrigin.xy, uv.x) + local * subTransform) * postScale, -1.0, mix(oldOrigin.z, newOrigin.z, uv.x));
        var_uv = var_uv * subTransform;
	}
    
    // Create some UVs for the noise texture which vary depending upon the location of the splat.
    var_noiseUv = var_uv + vec2(dot(origin, vec3(5.8, -6.4, 3.4)), dot(origin, vec3(-9.6, 2.6, 5.8)));
}