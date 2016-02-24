# thirdPerson

A camera instance is an object containing:

- transform: A transform matrix to apply this frame.
- transformPreviousDraw: A transform matrix to apply the previous frame.

    matrix = require "./../matrix.litcoffee"
    vector = require "./../vector.litcoffee"
    ik = require "./../ik.litcoffee"
    navmesh = require "./../navmesh.litcoffee"
    plane = require "./../plane.litcoffee"
    
## create

- A transform matrix to track.
- A number specifying how far the camera should be from the target.
- A number specifying how high above the target the camera should look.
- A number specifying how high above the target the camera should be.
- A number specifying how quickly the camera should move, where "0" is slowest
  and "1" is fastest.
- A number specifying how quickly the camera should track, where "0" is slowest
  and "1" is fastest.

Returns a new camera instance.

    create = (transform, distance, viewHeight, targetHeight, moveLag, trackLag) ->
        track: transform
        transform: []
        transformPreviousDraw: []
        location: []
        locationPreviousTick: []
        target: []
        targetPreviousTick: []
        side: []
        sidePreviousTick: []
        distance: distance
        viewHeight: viewHeight
        targetHeight: targetHeight
        moveLag: moveLag
        trackLag: trackLag
        firstTick: true
        firstDraw: true

## tick

- A camera instance.
- Optionally, a navmesh triangle to track from.  Used to prevent the camera
  passing through the floor when going up ramps.
- A number specifying how much gap to leave between the camera and the navmesh.

    offset = []
    upAxis = []
    forwardAxis = []

    tick = (cameraInstance, triangle, gap) ->
        if not cameraInstance.firstTick
            vector.copy cameraInstance.location, cameraInstance.locationPreviousTick
            vector.copy cameraInstance.side, cameraInstance.sidePreviousTick
            vector.copy cameraInstance.target, cameraInstance.targetPreviousTick
    
        matrix.getTranslation cameraInstance.track, cameraInstance.location
        matrix.getX cameraInstance.track, cameraInstance.side
        matrix.getY cameraInstance.track, upAxis
        vector.multiply.byScalar upAxis, cameraInstance.targetHeight, offset
        vector.add.vector cameraInstance.location, offset, cameraInstance.target
        
        vector.multiply.byScalar upAxis, cameraInstance.viewHeight, offset
        vector.add.vector cameraInstance.location, offset, cameraInstance.location
        
        matrix.getZ cameraInstance.track, forwardAxis
        vector.multiply.byScalar forwardAxis, cameraInstance.distance, offset
        vector.subtract.vector cameraInstance.location, offset, cameraInstance.location
        
        if triangle
            triangle = navmesh.constrain cameraInstance.location, triangle
            altitude = (plane.distance triangle.plane, cameraInstance.location) - gap
            if altitude < 0
                vector.multiply.byScalar triangle.plane.normal, altitude, offset
                vector.subtract.vector cameraInstance.location, offset, cameraInstance.location
        
        if cameraInstance.firstTick
            vector.copy cameraInstance.location, cameraInstance.locationPreviousTick
            vector.copy cameraInstance.side, cameraInstance.sidePreviousTick
            vector.copy cameraInstance.target, cameraInstance.targetPreviousTick
            cameraInstance.firstTick = false
        else
            vector.interpolate cameraInstance.locationPreviousTick, cameraInstance.location, cameraInstance.moveLag, cameraInstance.location
            vector.interpolate cameraInstance.sidePreviousTick, cameraInstance.side, cameraInstance.moveLag, cameraInstance.side
            vector.interpolate cameraInstance.targetPreviousTick, cameraInstance.target, cameraInstance.trackLag, cameraInstance.target
        
        return
            
## preDraw

    location = []
    target = []
    side = []

    preDraw = (cameraInstance, progress) ->
        if not cameraInstance.firstDraw
            matrix.copy cameraInstance.transform, cameraInstance.transformPreviousDraw
        
        vector.interpolate cameraInstance.locationPreviousTick, cameraInstance.location, progress, location
        vector.interpolate cameraInstance.targetPreviousTick, cameraInstance.target, progress, target
        vector.interpolate cameraInstance.sidePreviousTick, cameraInstance.side, progress, side
        
        ik.lookAt location, target, side, cameraInstance.transform
        matrix.invert cameraInstance.transform, cameraInstance.transform
        
        if cameraInstance.firstDraw
            matrix.copy cameraInstance.transform, cameraInstance.transformPreviousDraw
            cameraInstance.firstDraw = false
        return

    module.exports = { create, tick, preDraw }