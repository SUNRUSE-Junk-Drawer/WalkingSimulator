Given a vertex shader object and a fragment shader object, links them into a
program object and returns it.

	handleError = require "./../handleError.litcoffee"
	context = require "./context.litcoffee"

	module.exports = (vertexShader, fragmentShader) ->
		gl = context.context
		program = undefined
		try
			program = gl.createProgram()
			gl.attachShader program, vertexShader
			gl.attachShader program, fragmentShader
			gl.linkProgram program
			if not gl.getProgramParameter program, gl.LINK_STATUS then handleError "Failed to link a shader program; " + gl.getProgramInfoLog program
			program
		catch e
			if program
				gl.detachShader program, vertexShader
				gl.detachShader program, fragmentShader
				gl.deleteProgram program
			throw e