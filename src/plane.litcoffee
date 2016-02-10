A plane is an object containing:

- normal: A vector specifying the facing direction of the plane.
- distance: A number specifying how far from 0, 0, 0 along the normal the plane 
            is.
            
Exports an object.

    vector = require "./vector.litcoffee"
    tempA = []
    tempB = []

Call the "fromTriangle" property with three input vectors forming a clockwise 
triangle and an output object to create a plane on which those three vectors 
lie.  If the output object is undefined, an empty one is created.  The output 
object is returned.

    fromTriangle = (a, b, c, output) ->
        output = output or {}
        output.normal = output.normal or []
        vector.subtract.vector a, b, tempA
        vector.subtract.vector a, c, tempB
        vector.cross tempA, tempB, output.normal
        vector.normalize output.normal, output.normal
        output.distance = vector.dot output.normal, a
        output
            
Call the "distance" property with a plane and a vector.  The distance between
the plane and vector is returned.  If the vector is behind the plane, the
distance is negative.

    distance = (plane, input) -> (vector.dot plane.normal, input) - plane.distance
    
Call the "project" property with a plane, input vector and output vector to
write the nearest point to the input vector on the plane to the output vector.
    
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