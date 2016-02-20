#ik

    matrix = require "./matrix.litcoffee"
    vector = require "./vector.litcoffee"

    startEndDifference = []
    startEndNormal = []
    bendNormal = []
    midpoint = []
    joint = []
    sideNormal2 = []
    
## lookAt

- A vector specifying where to place the origin.
- A vector specifying (globally) where the transform's Z axis should point.
- A vector pointing (locally) where the transform's X axis should point.
- A matrix to populate with the transform computed.
    
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
        return
    
## computeLimb

- A vector specifying where the limb runs from.
- A vector specifying where the limb runs to.
- A number specifying the total length of the limb.
- A vector pointing (locally) where the X axis of the limb should point.
- A matrix to populate with the transform for the first half of the limb.
- A matrix to populate with the transform for the second half of the limb.

If the limb is asked to extend further than physically possible, it will fully
extend and leave a gap.
    
    computeLimb = (start, end, targetLength, sideNormal, startTransform, endTransform) ->
        vector.subtract.vector end, start, startEndDifference
        realLength = vector.normalize startEndDifference, startEndNormal
        
        if realLength > targetLength
            vector.multiply.byScalar startEndNormal, (targetLength / 2), joint
            vector.add.vector joint, start, joint
            lookAt start, joint, sideNormal, startTransform
            lookAt joint, end, sideNormal, endTransform
        else
            vector.cross startEndDifference, sideNormal, bendNormal        
            vector.normalize bendNormal, bendNormal
            
            # The two halves of the limb form a pair of square-based triangles.
            # Work out how far the bend should go based on Pythagoras' theorem.
            alongBend = Math.sqrt (Math.max 0, (((targetLength / 2) * (targetLength / 2)) - ((realLength / 2) * (realLength / 2))))
        
            vector.interpolate start, end, 0.5, midpoint
            vector.multiply.byScalar bendNormal, alongBend, joint
            vector.add.vector joint, midpoint, joint
            
            lookAt start, joint, sideNormal, startTransform
            lookAt joint, end, sideNormal, endTransform
        return
            
    module.exports = { lookAt, computeLimb }