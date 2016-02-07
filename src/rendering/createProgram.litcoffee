Given the source code for a vertex shader and the source code for a fragment
shader, compiles the shaders, links them into a program object and returns it.

	context = require "./context.litcoffee"
	createShader = require "./createShader.litcoffee"
	combineShadersIntoProgram = require "./combineShadersIntoProgram.litcoffee"

	module.exports = (vertexSource, fragmentSource) ->
		gl = context.context
		vertexShader = undefined
		try
			vertexShader = createShader gl.VERTEX_SHADER, vertexSource
			fragmentShader = undefined
			try
				fragmentShader = createShader gl.FRAGMENT_SHADER, fragmentSource
				return combineShadersIntoProgram vertexShader, fragmentShader
			finally
				if fragmentShader then gl.deleteShader fragmentShader
		finally
			if vertexShader then gl.deleteShader vertexShader