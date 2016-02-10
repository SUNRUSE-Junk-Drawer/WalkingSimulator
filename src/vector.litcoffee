Vectors are arrays of 3 numbers; X, Y and Z.
X runs from left to right.
Y runs from bottom to top.
Z runs from back to front.

This module exports an object.

    misc = require "./misc.litcoffee"

Given a vector, calling the "sum" property returns the sum of its components.

    sum = (vector) ->
        total = 0
        (total += component) for component in vector
        total
        
    unary = (callback) -> (input, output) ->
        (output[index] = callback value) for value, index in input
        return
        
Given an input vector and output vector, calling the "copy" property copies each
component from the input to the output.
        
    copy = unary (component) -> component
    
Given an input vector and output vector, calling the "negate" property writes
the negative of each component in the input vector to the output vector.
    
    negate = unary (component) -> -component
    
    binary = (callback) ->
        vector: (a, b, output) ->
            (output[index] = callback valueA, b[index]) for valueA, index in a
            return

        scalarBy: (a, b, output) ->
            (output[index] = callback a, valueB) for valueB, index in b
            return
            
        byScalar: (a, b, output) ->
            (output[index] = callback valueA, b) for valueA, index in a
            return
    
Given two input vectors and an output vector, calling "add.vector" adds each
component in the input vectors and writes the results to the output vector.

Given a number, an input vector and an output vector, calling "add.scalarBy" 
adds the number to each component in the vector and and writes the results to
the output vector.

Given an input vector, a number and an output vector, calling "add.byScalar" 
adds each component in the vector to the number and writes the result to
the output vector.
    
    add = binary (a, b) -> a + b
    
Given two input vectors and an output vector, calling "subtract.vector" 
subtracts each compenent in the second input vector from the equivalent in the
first input vector and writes the results to the output vector.

Given a number, an input vector and an output vector, calling 
"subtract.scalarBy" subtracts each component in the vector from the number and
writes the results to the output vector.

Given an input vector, a number and an output vector, calling 
"subtract.byScalar" subtracts the number from each component in the vector and
writes the results to the output vector.
    
    subtract = binary (a, b) -> a - b
    
Given two input vectors and an output vector, calling "multiply.vector" 
multiplies each compenent in the second input vector with the equivalent in the
first input vector and writes the results to the output vector.

Given a number, an input vector and an output vector, calling 
"multiply.scalarBy" multiplies the number by each component in the vector and
writes the results to the output vector.

Given an input vector, a number and an output vector, calling 
"multiply.byScalar" multiplies each component in the vector by the number and
writes the results to the output vector.
    
    multiply = binary (a, b) -> a * b
    
Given two input vectors and an output vector, calling "divide.vector" 
divides each compenent in the first input vector by the equivalent in the
second input vector and writes the results to the output vector.

Given a number, an input vector and an output vector, calling 
"divide.scalarBy" divides the number by each component in the vector and
writes the results to the output vector.

Given an input vector, a number and an output vector, calling 
"divide.byScalar" divides each component in the vector by the number and
writes the results to the output vector.
    
    divide = binary (a, b) -> a / b
    
Given two vectors, calling the "dot" property returns the dot product of those
two vectors.

    tempA = []
    tempB = []
    dot = (a, b) -> 
        multiply.vector a, b, tempA
        sum tempA
    
Given a vector, calling the "magnitudeSquared" property returns the square of
its magnitude.
    
    magnitudeSquared = (v) -> dot v, v
    
Given a vector, calling the "magnitude" property returns its magnitude.
    
    magnitude = (v) -> Math.sqrt magnitudeSquared v

Given two vectors, calling the "distanceSquared" property returns the square of
the distance between them.
    
    distanceSquared = (a, b) ->
        subtract.vector a, b, tempB
        magnitudeSquared tempB

Given two vectors, calling the "distance" property returns the distance between
them.
        
    distance = (a, b) ->
        subtract.vector a, b, tempB
        magnitude tempB
        
Given an input and output vector, calling the "normalize" property writes the
normalized/unit length version of the input to the output.  The magnitude of the
input vector is also returned.

    normalize = (input, output) ->
        len = magnitude input
        divide.byScalar input, len, output
        len
     
Given two input vectors and an output vector, calling the "cross" property
writes the cross product of the two input vectors to the output vector.
     
    cross = (a, b, output) ->
        copy a, tempA
        copy b, tempB
        output[0] = tempA[1] * tempB[2] - tempB[1] * tempA[2]
        output[1] = tempA[2] * tempB[0] - tempB[2] * tempA[0]
        output[2] = tempA[0] * tempB[1] - tempB[0] * tempA[1]
        return
        
Given an input vector to interpolate from, an input vector to interpolate to,
a number where 0 is "from" and 1 is "to", and an output vector, calling the
"interpolate" property writes the linear interpolation to the output vector.

    interpolate = (from, to, alpha, output) ->
        for fromValue, index in from
            toValue = to[index]
            output[index] = misc.interpolate fromValue, toValue, alpha
        return
        
    module.exports = { 
            sum, copy, negate
            add, subtract, multiply, divide
            dot, cross
            magnitudeSquared, magnitude
            distanceSquared, distance
            normalize
            interpolate
        }