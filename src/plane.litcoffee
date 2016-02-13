# plane

A plane is an object containing:

- normal: A vector specifying the facing direction of the plane.
- distance: A number specifying how far from 0, 0, 0 along the normal the plane 
            is.

    vector = require "./vector.litcoffee"
    tempA = []
    tempB = []

## fromTriangle

- A vector specifying the location of the first vertex.
- A vector specifying the location of the second vertex.
- A vector specifying the location of the third vertex.
- An existing object to populate, else, falsy.

The populated object is returned.

    fromTriangle = (a, b, c, output) ->
        output = output or {}
        output.normal = output.normal or []
        vector.subtract.vector a, b, tempA
        vector.subtract.vector a, c, tempB
        vector.cross tempB, tempA, output.normal
        vector.normalize output.normal, output.normal
        output.distance = vector.dot output.normal, a
        output
            
## distance

- A plane.
- A vector.

Returns the distance between the plane and the vector.  Negative when behind the
plane.

    distance = (plane, input) -> (vector.dot plane.normal, input) - plane.distance
    
## project

- A plane.
- An input vector.
- An output vector.

Projects the input vector onto the surface of the plane, travelling along its
normal to find the closest point, and writes that point to the output vector.
    
    project = (plane, input, output) ->
        dist = distance plane, input
        vector.multiply.scalarBy dist, plane.normal, tempA
        vector.subtract.vector input, tempA, output
        return
    
    module.exports = {
        fromTriangle
        distance
        project
    }