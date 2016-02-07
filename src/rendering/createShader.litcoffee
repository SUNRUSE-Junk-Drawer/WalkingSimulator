Given the source code for a shader, compiles it and returns the shader object.

	context = require "./context.litcoffee"
	handleError = require "./../handleError.litcoffee"

	module.exports = (type, source) ->
		gl = context.context
		shader = undefined
		try
			shader = gl.createShader type
			gl.shaderSource shader, source
			gl.compileShader shader
			if not gl.getShaderParameter shader, gl.COMPILE_STATUS then handleError "Failed to compile a shader; " + gl.getShaderInfoLog shader
			return shader
		catch e
			if shader then gl.deleteShader(shader)
			throw e