# firstPerson

A camera instance is an object containing:

- transform: A transform matrix to apply this frame.
- transformPreviousDraw: A transform matrix to apply the previous frame.

    matrix = require "./../matrix.litcoffee"
    vector = require "./../vector.litcoffee"
    navmesh = require "./../navmesh.litcoffee"
    misc = require "./../misc.litcoffee"
    plane = require "./../plane.litcoffee"
    
## create

- An object equivalent to the "gamepad" module.
- A navmesh instance to track.
- A vector specifying the initial location of the camera.
- The initial yaw, in radians.
- The initial pitch, in radians.
- The speed, in units per tick, at which the camera may move horizontally.
- The speed, in radians per tick, at which the camera may yaw.
- The speed, in radians per tick, at which the camera may pitch.
- The height above the ground at which to place the camera.

Returns a new camera instance.

    create = (gamepad, navmeshInstance, location, yaw, pitch, speed, yawSpeed, pitchSpeed, height) ->
        locationCopy = []
        vector.copy location, locationCopy
        previousLocation = []
        vector.copy location, previousLocation

        location: locationCopy
        previousLocation: previousLocation
        interpolatedLocation: []
        transform: []
        transformPreviousDraw: []
        
        firstTick: true
        firstDraw: true
        
        triangle: navmesh.findNearest navmeshInstance, location
        
        gamepad: gamepad
        pitch: pitch
        yaw: yaw
        previousPitch: pitch
        previousYaw: yaw
        speed: speed
        yawSpeed: yawSpeed
        pitchSpeed: pitchSpeed
        
        height: height

## tick

- A camera instance.

    tick = (cameraInstance) ->
        if not cameraInstance.firstTick
            vector.copy cameraInstance.location, cameraInstance.previousLocation
            cameraInstance.previousYaw = cameraInstance.yaw
            cameraInstance.previousPitch = cameraInstance.pitch
            
        cameraInstance.yaw += (cameraInstance.gamepad.right - cameraInstance.gamepad.left) * cameraInstance.yawSpeed
        
        cameraInstance.pitch += (cameraInstance.gamepad.down - cameraInstance.gamepad.up) * cameraInstance.pitchSpeed
        cameraInstance.pitch = Math.min (Math.PI / 2), Math.max (Math.PI / -2), cameraInstance.pitch
        
        forward = (cameraInstance.gamepad.forward - cameraInstance.gamepad.backward) * cameraInstance.speed
        cameraInstance.location[0] += (Math.sin cameraInstance.yaw) * forward
        cameraInstance.location[2] += (Math.cos cameraInstance.yaw) * forward
        
        cameraInstance.triangle = navmesh.constrain cameraInstance.location, cameraInstance.triangle
        plane.project cameraInstance.triangle.plane, cameraInstance.location, cameraInstance.location
        
        if cameraInstance.firstTick
            vector.copy cameraInstance.location, cameraInstance.previousLocation
            cameraInstance.firstTick = false
        
        return
            
## preDraw

- A camera instance.
- The progress through the current tick, where "0" is the previous tick and "1"
  is the new tick.

    interpolatedLocation = []

    preDraw = (cameraInstance, progress) ->
        if not cameraInstance.firstDraw
            matrix.copy cameraInstance.transform, cameraInstance.transformPreviousDraw
        
        matrix.identity cameraInstance.transform
        
        vector.interpolate cameraInstance.previousLocation, cameraInstance.location, progress, interpolatedLocation
        interpolatedLocation[1] += cameraInstance.height
        vector.negate interpolatedLocation, interpolatedLocation
        matrix.translate interpolatedLocation, cameraInstance.transform
        
        matrix.rotateY (misc.interpolate cameraInstance.previousYaw, cameraInstance.yaw, progress), cameraInstance.transform
        
        matrix.rotateX (misc.interpolate cameraInstance.previousPitch, cameraInstance.pitch, progress), cameraInstance.transform
        
        matrix.translate [0, 0, 0], cameraInstance.transform
        
        if cameraInstance.firstDraw
            matrix.copy cameraInstance.transform, cameraInstance.transformPreviousDraw
            cameraInstance.firstDraw = false
        return

    module.exports = { create, tick, preDraw }