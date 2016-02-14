Matrices are arrays of 16 numbers forming a 4x4 matrix.

    temp1 = []
    temp2 = []
    rotationTemp = []
    tempVector = []
    tempVectorFrom = []
    tempVectorTo = []
    fromTemp = []
    toTemp = []
    tempVectorX = []
    tempVectorY = []
    tempVectorZ = []
    
    makeRotate = (axis1, axis2, axis3, axis4) ->
        temp3 = []
        rotationTemp.push temp3
        (radians, output) ->
            sin = Math.sin radians
            cos = Math.cos radians
            temp3[axis1] = cos
            temp3[axis2] = -sin
            temp3[axis3] = sin
            temp3[axis4] = cos
            module.exports.multiply output, temp3, output
            return

    vector = require "./vector.litcoffee"
            
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
        
Given a vector specifying the scaling factor on each axis and a matrix, calling
the "scale" property scales the matrix by those scaling factors.
        
        scale: (vector, output) ->
            output[index] *= vector[0] for index in [0...4]
            output[index] *= vector[1] for index in [4...8]
            output[index] *= vector[2] for index in [8...12]
            return

Given a vector specifying a translation and a matrix to translate, calling the 
"translate" property applies that translation to that matrix.
            
        translate: (vector, output) ->
            output[3] += vector[0]
            output[7] += vector[1]
            output[11] += vector[2]
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
            
Given a matrix, input vector and output vector, calling the "applyToVector"
property writes the input vector transformed by the matrix to the output vector.
        
        applyToVector: (matrix, input, output) ->
            vector.copy input, vectorTemp
            output[0] = vectorTemp[0] * matrix[0] + vectorTemp[1] * matrix[1] + vectorTemp[2] * matrix[2] + matrix[3]
            output[1] = vectorTemp[0] * matrix[4] + vectorTemp[1] * matrix[5] + vectorTemp[2] * matrix[6] + matrix[7]
            output[2] = vectorTemp[0] * matrix[8] + vectorTemp[1] * matrix[9] + vectorTemp[2] * matrix[10] + matrix[11]
            return
            
Given a matrix and output vector, calling the "getTranslation" property writes
the translation applied by the matrix to the output vector.

        getTranslation: (matrix, output) ->
            output[0] = matrix[3]
            output[1] = matrix[7]
            output[2] = matrix[11]

Given a matrix and output vector, calling the "getX" property writes the vector
of the matrix's X axis (a scaled normal) to the output vector.

        getX: (matrix, output) ->
            output[0] = matrix[0]
            output[1] = matrix[1]
            output[2] = matrix[2]

Given a matrix and output vector, calling the "getY" property writes the vector
of the matrix's Y axis (a scaled normal) to the output vector.

        getY: (matrix, output) ->
            output[0] = matrix[4]
            output[1] = matrix[5]
            output[2] = matrix[6]
            
Given a matrix and output vector, calling the "getZ" property writes the vector
of the matrix's Z axis (a scaled normal) to the output vector.

        getZ: (matrix, output) ->
            output[0] = matrix[8]
            output[1] = matrix[9]
            output[2] = matrix[10]
            
# setTranslation

- A vector specifying the translation to set.
- A matrix to set the translation of.

Overwrites the translation of the matrix with the content of the given vector.

        setTranslation: (output, matrix) ->
            matrix[3] = output[0]
            matrix[7] = output[1]
            matrix[11] = output[2]

# setX

- A vector specifying the X axis vector to set.
- A matrix to set the X axis vector of.

Overwrites the X axis of the matrix with the content of the given vector.

        setX: (output, matrix) ->
            matrix[0] = output[0]
            matrix[1] = output[1]
            matrix[2] = output[2]

# setY

- A vector specifying the Y axis vector to set.
- A matrix to set the Y axis vector of.

Overwrites the Y axis of the matrix with the content of the given vector.

        setY: (output, matrix) ->
            matrix[4] = output[0]
            matrix[5] = output[1]
            matrix[6] = output[2]

# setZ

- A vector specifying the Z axis vector to set.
- A matrix to set the Z axis vector of.

Overwrites the Z axis of the matrix with the content of the given vector.

        setZ: (output, matrix) ->
            matrix[8] = output[0]
            matrix[9] = output[1]
            matrix[10] = output[2]
            
# interpolate

- An input matrix to interpolate from.
- An input matrix to interpolate to.
- A number specifying how far along to interpolate; "0" is "from" and "1" is 
  "to".
- An output matrix.

Attempts to perform a somewhat crude interpolation between the two matrices
which is not very linear.  Good enough for smoothing over small changes.
Prioritizes the Z and Y axes over the X axis when ensuring orthogonal.

        interpolate: (from, to, alpha, output) ->       
            module.exports.copy from, fromTemp
            module.exports.copy to, toTemp
            module.exports.identity output
            module.exports.getTranslation fromTemp, tempVectorFrom
            module.exports.getTranslation toTemp, tempVectorTo
            vector.interpolate tempVectorFrom, tempVectorTo, alpha, tempVector
            module.exports.setTranslation tempVector, output
            
            module.exports.getX fromTemp, tempVectorFrom
            module.exports.getX toTemp, tempVectorTo
            vector.interpolate tempVectorFrom, tempVectorTo, alpha, tempVector
            vector.normalize tempVector, tempVectorX, true  
            
            module.exports.getY fromTemp, tempVectorFrom
            module.exports.getY toTemp, tempVectorTo
            vector.interpolate tempVectorFrom, tempVectorTo, alpha, tempVectorY
            
            vector.cross tempVectorX, tempVectorY, tempVectorZ
            vector.normalize tempVectorZ, tempVectorZ
            vector.cross tempVectorZ, tempVectorX, tempVectorY
            vector.normalize tempVectorY, tempVectorY
            
            module.exports.setX tempVectorX, output
            module.exports.setY tempVectorY, output
            module.exports.setZ tempVectorZ, output
            return
            
    module.exports.identity temp1
    module.exports.identity temp2
    for mat in rotationTemp
        module.exports.identity mat