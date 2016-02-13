# vector

Vectors are arrays of 3 numbers; X, Y and Z.
X runs from left to right.
Y runs from bottom to top.
Z runs from back to front.

When given as outputs, vectors can safely be empty arrays.

    misc = require "./misc.litcoffee"

## sum

- A vector.

Returns the sum of the components.

    sum = (vector) ->
        total = 0
        (total += component) for component in vector
        total
        
    unary = (callback) -> (input, output) ->
        (output[index] = callback value) for value, index in input
        return
        
## copy

- An input vector.
- An output vector.

Copies every component from the input to the output.
        
    copy = unary (component) -> component
    
## copy

- An input vector.
- An output vector.

Writes the negative of every component of the input to the output.
    
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
    
## add.vector

- An input vector.
- An input vector.
- An output vector.
    
Adds each component in the input vectors and writes the results to the output 
vector.

## add.scalarBy

- A number.
- An input vector.
- An output vector.

Adds the number to each component in the vector and and writes the results to
the output vector.

## add.byScalar

- An input vector.
- A number.
- An output vector.

Adds each component in the vector to the number and writes the result to
the output vector.
    
    add = binary (a, b) -> a + b
    
## subtract.vector

- An input vector.
- An input vector.
- An output vector.
    
Subtracts each compenent in the second input vector from the equivalent in the
first input vector and writes the results to the output vector.

## subtract.scalarBy

- A number.
- An input vector.
- An output vector.

Subtracts each component in the vector from the number and writes the results to 
the output vector.

## subtract.byScalar

- An input vector.
- A number.
- An output vector.

Subtracts the number from each component in the vector and writes the results to 
the output vector.
    
    subtract = binary (a, b) -> a - b
    
## multiply.vector

- An input vector.
- An input vector.
- An output vector.
    
Multiplies each compenent in the second input vector with the equivalent in the
first input vector and writes the results to the output vector.

## multiply.scalarBy

- A number.
- An input vector.
- An output vector.

Multiplies the number by each component in the vector and writes the results to 
the output vector.

## multiply.byScalar

- An input vector.
- A number.
- An output vector.

Multiplies each component in the vector by the number and writes the results to 
the output vector.
    
    multiply = binary (a, b) -> a * b
    
## divide.vector

- An input vector.
- An input vector.
- An output vector.
    
Divides each compenent in the first input vector by the equivalent in the second
input vector and writes the results to the output vector.

## divide.scalarBy

- A number.
- An input vector.
- An output vector.

Divides the number by each component in the vector and writes the results to the
output vector.

## divide.byScalar

- An input vector.
- A number.
- An output vector.

Divides each component in the vector by the number and writes the results to the
output vector.
    
    divide = binary (a, b) -> a / b
    
# dot
    
- A vector.
- A vector.

Returns the dot product of the two vectors.

    tempA = []
    tempB = []
    dot = (a, b) -> 
        multiply.vector a, b, tempA
        sum tempA
    
# magnitudeSquared

- A vector.

Returns the square of the magnitude/length of the vector.
Faster than "magnitude".
    
    magnitudeSquared = (v) -> dot v, v
    
# magnitude

- A vector.

Returns the magnitude/length of the vector.
Slower than "magnitudeSquared".
    
    magnitude = (v) -> Math.sqrt magnitudeSquared v

# distanceSquared

- A vector.
- A vector.

Returns the square of the distance between the two vectors.
Faster than "distance".
    
    distanceSquared = (a, b) ->
        subtract.vector a, b, tempB
        magnitudeSquared tempB

# distance

- A vector.
- A vector.

Returns the distance between the two vectors.
Slower than "distanceSquared".

    distance = (a, b) ->
        subtract.vector a, b, tempB
        magnitude tempB
        
# normalize

- An input vector.
- An output vector.

Writes the normalized/unit length version of the input vector to the output.
Returns the magnitude/length of the original vector.

    normalize = (input, output) ->
        len = magnitude input
        divide.byScalar input, len, output
        len
     
# cross

- An input vector.
- An input vector.
- An output vector.

Writes the cross product of the two input vectors to the output vector.
     
    cross = (a, b, output) ->
        copy a, tempA
        copy b, tempB
        output[0] = tempA[1] * tempB[2] - tempB[1] * tempA[2]
        output[1] = tempA[2] * tempB[0] - tempB[2] * tempA[0]
        output[2] = tempA[0] * tempB[1] - tempB[0] * tempA[1]
        return
        
# interpolate

- An input vector to interpolate from.
- An input vector to interpolate to.
- A number, where "0" is "from" and "1" is "to".
- An output vector.

Writes the linear interpolation between, or linear extrapolation beyond, the
two input vectors to the output.

    interpolate = (from, to, alpha, output) ->
        for fromValue, index in from
            toValue = to[index]
            output[index] = misc.interpolate fromValue, toValue, alpha
        return
        
# reflect

- An input vector.
- An input normal vector.
- An output vector.

Writes the reflection of the input vector against the surface normal specified
to the output vector.
        
    reflectTemp = []
    reflect = (input, normal, output) ->
        coefficient = dot input, normal
        multiply.byScalar normal, (coefficient * 2), reflectTemp
        subtract.vector input, reflectTemp, output
        
# flatten

- An input vector.
- An input normal vector.
- An output vector.

Writes the input vector to the output vector, but "flattened" along the surface
normal.  For instance, a vector pointing up and right with a normal facing right
would output a vector pointing only up.

    flattenTemp = []
    flatten = (input, normal, output) ->
        matched = dot input, normal
        multiply.byScalar normal, matched, flattenTemp
        subtract.vector input, flattenTemp, output
        
    module.exports = { 
            sum, copy, negate
            add, subtract, multiply, divide
            dot, cross
            magnitudeSquared, magnitude
            distanceSquared, distance
            normalize
            interpolate
            reflect, flatten
        }