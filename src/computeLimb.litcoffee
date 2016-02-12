Given:

- A vector locating the start of the limb.
- A vector locating the end of the limb.
- The length of the limb when fully extended.
- A vector pointing perpendicular to the bend direction.
- A matrix to store the transform for the start half of the limb.
- A matrix to store the transform for the end half of the limb.

Writes to the output matrices to generate transforms for the top and bottom
halves of a limb to fill the gap between the start and end locations.

    matrix = require "./matrix.litcoffee"
    vector = require "./vector.litcoffee"

    startEndDifference = []
    startEndNormal = []
    bendNormal = []
    midpoint = []
    joint = []
    sideNormal2 = []
    
    lookAt = (start, end, sideNormal, transform) ->
        vector.subtract.vector end, start, startEndDifference
        vector.normalize startEndDifference, startEndNormal
        vector.cross startEndNormal, sideNormal, bendNormal
        vector.normalize bendNormal, bendNormal
        vector.cross bendNormal, startEndNormal, sideNormal2
        vector.normalize sideNormal2, sideNormal2
  
        matrix.identity transform
        transform[0] = sideNormal2[0]
        transform[4] = sideNormal2[1]
        transform[8] = sideNormal2[2]
        transform[1] = bendNormal[0]
        transform[5] = bendNormal[1]
        transform[9] = bendNormal[2]
        transform[2] = startEndNormal[0]
        transform[6] = startEndNormal[1]
        transform[10] = startEndNormal[2]
        matrix.translate start, transform
    
    module.exports = (start, end, targetLength, sideNormal, startTransform, endTransform) ->
        vector.subtract.vector end, start, startEndDifference
        vector.cross startEndDifference, sideNormal, bendNormal
        realLength = vector.normalize startEndDifference, startEndNormal
        vector.normalize bendNormal, bendNormal
        
        # The two halves of the limb form a pair of square-based triangles.
        # Work out how far the bend should go based on Pythagoras' theorem.
        alongBend = Math.sqrt (Math.max 0, (((targetLength / 2) * (targetLength / 2)) - ((realLength / 2) * (realLength / 2))))
    
        vector.interpolate start, end, 0.5, midpoint
        vector.multiply.byScalar bendNormal, alongBend, joint
        vector.add.vector joint, midpoint, joint
        
        lookAt start, joint, sideNormal, startTransform
        lookAt joint, end, sideNormal, endTransform