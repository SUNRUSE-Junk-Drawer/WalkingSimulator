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
        
        vector.subtract.vector end, joint, startEndDifference
        vector.normalize startEndDifference, startEndNormal
        vector.cross sideNormal, startEndDifference, bendNormal
        vector.normalize bendNormal, bendNormal
        vector.cross bendNormal, startEndDifference, sideNormal2
        vector.normalize sideNormal2, sideNormal2
    
        matrix.identity endTransform
        endTransform[0] = -sideNormal2[0]
        endTransform[1] = -sideNormal2[1]
        endTransform[2] = sideNormal2[2]
        endTransform[4] = -bendNormal[0]
        endTransform[5] = -bendNormal[1]
        endTransform[6] = bendNormal[2]
        endTransform[8] = -startEndNormal[0]
        endTransform[9] = -startEndNormal[1]
        endTransform[10] = startEndNormal[2]
        matrix.translate joint, endTransform
        
        vector.subtract.vector joint, start, startEndDifference
        vector.normalize startEndDifference, startEndNormal
        vector.cross sideNormal, startEndDifference, bendNormal
        vector.normalize bendNormal, bendNormal
        vector.cross bendNormal, startEndDifference, sideNormal2
        vector.normalize sideNormal2, sideNormal2
        
        matrix.identity startTransform
        startTransform[0] = -sideNormal2[0]
        startTransform[1] = -sideNormal2[1]
        startTransform[2] = sideNormal2[2]
        startTransform[4] = -bendNormal[0]
        startTransform[5] = -bendNormal[1]
        startTransform[6] = bendNormal[2]
        startTransform[8] = -startEndNormal[0]
        startTransform[9] = -startEndNormal[1]
        startTransform[10] = startEndNormal[2]
        matrix.translate start, startTransform