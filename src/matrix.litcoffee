Matrices are arrays of 16 numbers forming a 4x4 matrix.

	temp1 = []
	temp2 = []
	temp3 = []
	
	makeRotate = (axis1, axis2, axis3, axis4) -> (radians, output) ->
		sin = Math.sin radians
		cos = Math.cos radians
		temp3[axis1] = cos
		temp3[axis2] = -sin
		temp3[axis3] = sin
		temp3[axis4] = cos
		module.exports.multiply output, temp3, output
		return

	module.exports = 

Given a matrix, calling the "identity" property writes the identity matrix to 
it.

		identity: (output) ->
			for row in [0...4]
				for column in [0...4]
					output[row * 4 + column] = if row is column then 1 else 0
			return
		
Given two matrices, calling the "copy" property copies every component from the 
first to the second.

		copy: (input, output) ->
			output[index] = value for value, index in input
			return
			
Given three matrices, calling the "multiply" property multiplies the first two 
together and writes the result to the third.

		multiply: (a, b, output) ->
			module.exports.copy a, temp1
			module.exports.copy b, temp2
				
			for row in [0...4]
				for column in [0...4]
					temp = 0
					for component in [0...4]
						temp += temp1[component * 4 + column] * temp2[row * 4 + component]
					output[row * 4 + column] = temp
			return
			
Given a number of radians and a matrix, calling the "rotateX" property modifies 
the matrix to have been rotated by that number of radians about the X axis.
			
		rotateX: makeRotate 5, 6, 9, 10
		
Given a number of radians and a matrix, calling the "rotateY" property modifies 
the matrix to have been rotated by that number of radians about the Y axis.
		
		rotateY: makeRotate 0, 2, 8, 10

Given a number of radians and a matrix, calling the "rotateZ" property modifies 
the matrix to have been rotated by that number of radians about the Z axis.
		
		rotateZ: makeRotate 0, 1, 4, 5
		
Given the X, Y and Z scaling factors and a matrix, calling the "scale" property
scales the matrix by those scaling factors.
		
		scale: (x, y, z, output) ->
			output[index] *= x for index in [0...4]
			output[index] *= y for index in [4...8]
			output[index] *= z for index in [8...12]
			return

Given the X, Y and Z values to translate by and a matrix to translate, calling
the "translate" property applies that translation to that matrix.
			
		translate: (x, y, z, output) ->
			output[3] += x
			output[7] += y
			output[11] += z
			return
			
Given a matrix, X, Y, Z and W values (defaulting to 0, 0, 0 and 1 respectively
if not given), calling the "apply" property returns an array of four numbers 
representing the transformed vector.

		apply: (matrix, x, y, z, w) ->
			if x is undefined then x = 0
			if y is undefined then y = 0
			if z is undefined then z = 0
			if w is undefined then w = 1
			
			[
				x * matrix[0] + y * matrix[1] + z * matrix[2] + w * matrix[3]
				x * matrix[4] + y * matrix[5] + z * matrix[6] + w * matrix[7]
				x * matrix[8] + y * matrix[9] + z * matrix[10] + w * matrix[11]
				x * matrix[12] + y * matrix[13] + z * matrix[14] + w * matrix[15]
			]
			
	module.exports.identity temp1
	module.exports.identity temp2
	module.exports.identity temp3