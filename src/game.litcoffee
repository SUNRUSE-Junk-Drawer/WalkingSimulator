# game

This module contains your game logic.  Its methods are called by the "index"
module to update the game state.

    gamepad = require "./input/gamepad.litcoffee"
    keyboard = require "./input/keyboard.litcoffee"
    
    context = require "./rendering/context.litcoffee"
    cloud = require "./rendering/cloud.litcoffee"
    matrix = require "./matrix.litcoffee"
    plane = require "./plane.litcoffee"
    misc = require "./misc.litcoffee"
    navmesh = require "./navmesh.litcoffee"
    vector = require "./vector.litcoffee"
    pose = require "./pose.litcoffee"
    ik = require "./ik.litcoffee"
       
    triangle = undefined
    
    character = testMap = testNavmesh = undefined
    characterData = require "./characters/test/cloud.coffee"

# load
Called before the first "tick"/"draw" to load any resources needed by the game.
Execute the argument when you have finished successfully.

    load = (callback) ->
        keyboard()
        context.load()
        cloud.load characterData, (character_) ->
            character = character_
            cloud.load (require "./tracks/test/geometry.msc"), (testMap_) ->
                testMap = testMap_
                navmesh.load (require "./tracks/test/navmesh.msn"), (testNavmesh_) ->
                    testNavmesh = testNavmesh_
                    triangle = testNavmesh[0]
                    callback()
                    return
                return
            return
        return
    
# tick
Called at 20Hz to update game state.  Guaranteed to be called once between 
"load" and "draw".  May be called more or than once per call to "draw" or not at
all.

    firstTick = true
    firstDraw = true
    
    entityTransform = []
    entityTransformToDraw = []
    entityTransformPreviousTick = []
    entityTransformPreviousDraw = []
    matrix.identity entityTransform
    
    playerPoseOld = pose.create characterData
    playerPoseNew = pose.create characterData
    
    torsoTransform = []
    torsoTransformToDraw = []
    torsoTransformPreviousTick = []
    torsoTransformPreviousDraw = []

    surfaceCorrectedEntityTransform = []
    matrix.identity surfaceCorrectedEntityTransform

    cameraTransform = []
    cameraTransformPreviousDraw = []
    matrix.identity cameraTransform
    
    torsoAltitude = 0

    velocity = [0, 0, 0]    
    xAxis = []
    yAxis = []
    zAxis = []
    torsoXAxis = []
    torsoZAxis = []
    translation = []
    targetForwardVelocity = []
    targetSidewardVelocity = []
    targetVelocity = []
    torsoTranslation = []
    
    start = []
    leftFoot = []
    rightFoot = []
    leftHand = []
    leftHandPreviousTick = []
    leftHandToDraw = []
    rightHand = []
    rightHandPreviousTick = []
    rightHandToDraw = []
    walked = 0
    shuffleTicks = 0
    foot = "left"
    ticksSinceLeft = 0
    ticksSinceRight = 0
    offset = []
    
    yaw = 0
    pitch = 0
    headYawPreviousTick = headYaw = 0
    
    stick = [0, 0, 0]
    stickAngle = 0
    
    edgeCallback = (edge) -> vector.flatten velocity, edge.plane.normal, velocity
    
    tick = ->        
        if not firstTick
            matrix.copy entityTransform, entityTransformPreviousTick
            matrix.copy torsoTransform, torsoTransformPreviousTick
            vector.copy leftHand, leftHandPreviousTick
            vector.copy rightHand, rightHandPreviousTick
            
        matrix.translate velocity, entityTransform  
        speed = vector.magnitude velocity
        walked += speed
        moving = speed > 2
        
        stick[0] = gamepad.right - gamepad.left
        stick[1] = gamepad.forward - gamepad.backward
        stickLength = vector.magnitude stick
        
        inDeadzone = stickLength < 0.1
        
        if inDeadzone 
            stick[0] = stick[1] = 0
        else 
            stickAngle = Math.atan2 -stick[0], stick[1]
            if stickLength > 1                
                vector.divide.byScalar stick, stickLength, stick
                stickLength = 1
        
        # Left/right rotation.
        matrix.rotateY (stick[0] * -0.1), entityTransform, true
        
        # Apply navmesh triangle collision.
        matrix.getTranslation entityTransform, translation
        triangle = navmesh.constrain translation, triangle, edgeCallback
        
        # Gravity.
        velocity[1] -= 0.2
        
        # Forwards/backwards movement.
        matrix.getZ entityTransform, zAxis
        
        # Determine if we're underground.
        altitude = plane.distance triangle.plane, translation
        
        if altitude < 0
            velocity = velocity
            plane.project triangle.plane, translation, translation
            
            # A "bump" when you land.
            matrix.getY entityTransform, yAxis
            impact = Math.abs (vector.dot triangle.plane.normal, velocity) * (vector.dot triangle.plane.normal, yAxis)
            impact -= 1
            if impact < 0 then impact = 0
            impact *= 2
            torsoAltitude -= impact
            
            # Reflecting the velocity against the hit surface but then 
            # flattening it has the effect that hitting a ramp bounces you up it
            # but you don't bounce when falling onto the floor.
            vector.reflect velocity, triangle.plane.normal, velocity
            vector.flatten velocity, triangle.plane.normal, velocity
        
            if not inDeadzone
                matrix.getX entityTransform, xAxis
                vector.multiply.byScalar zAxis, (stick[1] * 10), targetForwardVelocity                
                vector.multiply.byScalar xAxis, (stick[0] * 10), targetSidewardVelocity                
                vector.add.vector targetForwardVelocity, targetSidewardVelocity, targetVelocity
            else
                targetVelocity[0] = targetVelocity[1] = targetVelocity[2] = 0
            vector.interpolate velocity, targetVelocity, 0.05, velocity
            
        # Apply air resistance.
        vector.multiply.byScalar velocity, 0.98, velocity
        
        # This section attempts to align the entity with the triangle surface.
        
        # We take the triangle's normal as the Y/up axis.
        
        # First, flatten the Z/forward axis onto the surface.
        vector.flatten zAxis, triangle.plane.normal, zAxis
        vector.normalize zAxis, zAxis
        
        # Then, find the X/right axis which is perpendicular to the Z/forward 
        # and Y/up axes.
        vector.cross triangle.plane.normal, zAxis, xAxis
        matrix.setX xAxis, surfaceCorrectedEntityTransform
        matrix.setY triangle.plane.normal, surfaceCorrectedEntityTransform
        matrix.setZ zAxis, surfaceCorrectedEntityTransform
        
        # Blend between our current transform and the aligned one.
        matrix.interpolate entityTransform, surfaceCorrectedEntityTransform, 0.1, entityTransform
        
        matrix.setTranslation translation, entityTransform
        
        matrix.copy entityTransform, torsoTransform
        
        torsoAltitude = misc.interpolate torsoAltitude, (12 - Math.min 2, (speed + if inDeadzone then 0 else 1.5)), 0.4
        
        matrix.getY entityTransform, yAxis
        vector.multiply.byScalar yAxis, torsoAltitude, torsoTranslation
        vector.add.vector torsoTranslation, translation, torsoTranslation
        
        yaw = misc.interpolateAngle yaw, stickAngle, 0.1, yaw
        matrix.rotateY yaw, torsoTransform, true
        
        # Calculating the head angle relative to the torso is complicated by the
        # stick angle being wrapped to 0...2PI, so we have to shift it out of
        # that range to clamp it.
        headYawPreviousTick = headYaw
        headYaw = Math.max Math.PI - 1, Math.min Math.PI + 1, misc.wrapAngle Math.PI + stickAngle - yaw
        headYaw -= Math.PI
        headYaw = misc.interpolateAngle headYawPreviousTick, headYaw, 0.4, headYaw
        
        matrix.getZ torsoTransform, torsoZAxis # TODO: If the entity transform is ever non-identity at startup we'll need to initialize torsoTransform for this to be right in the first ticks.
        matrix.getX torsoTransform, torsoXAxis # TODO: If the entity transform is ever non-identity at startup we'll need to initialize torsoTransform for this to be right in the first ticks.
        pitch = misc.interpolate pitch, (0.5 * stickLength - 0.1 * vector.dot torsoZAxis, velocity), 0.4
        matrix.rotateX pitch, torsoTransform, true
        matrix.rotateZ (0.1 * vector.dot torsoXAxis, velocity), torsoTransform, true
        
        matrix.setTranslation torsoTranslation, torsoTransform
        
        shuffleTicks--
        ticksSinceLeft++
        ticksSinceRight++
        while walked > 5 or shuffleTicks < 0
            shuffleTicks = 5
            walked -= 5
            if (not inDeadzone) or moving
                vector.normalize velocity, offset
                vector.multiply.byScalar offset, 5, offset
            else
                offset[0] = offset[1] = offset[2] = 0
            foot = switch foot
                when "left"
                    matrix.applyToVector playerPoseNew.torso, [-2, -10, 0], leftFoot
                    vector.add.vector offset, leftFoot, leftFoot
                    plane.project triangle.plane, leftFoot, leftFoot
                    ticksSinceLeft = 0
                    "right"
                when "right"
                    matrix.applyToVector playerPoseNew.torso, [2, -10, 0], rightFoot
                    vector.add.vector offset, rightFoot, rightFoot
                    plane.project triangle.plane, rightFoot, rightFoot
                    ticksSinceRight = 0
                    "left"
        
        if inDeadzone
            leftHand[0] = -6
            rightHand[0] = 6
            leftHand[1] = rightHand[1] = -4
            leftHand[2] = rightHand[2] = 0
        else
            yScale = 7 / (1 + speed)
            rightHand[0] = 2 + (Math.min 4, speed)
            leftHand[0] = -rightHand[0]
            
            leftHand[1] = rightHand[1] = 3
            motion = Math.pow (Math.cos ticksSinceLeft * 0.25) * 0.5 + 0.5, 4
            leftHand[1] += yScale * motion
            leftHand[2] = 1.5 + 6 * stickLength * motion
            motion = Math.pow (Math.cos ticksSinceRight * 0.25) * 0.5 + 0.5, 4
            rightHand[1] += yScale * motion
            rightHand[2] = 1.5 + 6 * stickLength * motion
            
        matrix.applyToVector torsoTransform, leftHand, leftHand                
        matrix.applyToVector torsoTransform, rightHand, rightHand
        
        leftHand[1] -= 2
        rightHand[1] -= 2
        
        if firstTick
            matrix.copy entityTransform, entityTransformPreviousTick
            matrix.copy torsoTransform, torsoTransformPreviousTick
            vector.copy leftHand, leftHandPreviousTick
            vector.copy rightHand, rightHandPreviousTick
            firstTick = false
            
        lag = 0.15 + 0.4 / (1 + speed / 3)
        if inDeadzone then lag = 0.2
        vector.interpolate leftHandPreviousTick, leftHand, lag, leftHand
        vector.interpolate rightHandPreviousTick, rightHand, lag, rightHand
            
        return
  
# draw
Called with the progress through the current frame (a number between 0 and 1) to 
redraw the scene.
  
    draw = (progress) ->     
    
        if not firstDraw
            matrix.copy entityTransformToDraw, entityTransformPreviousDraw
            matrix.copy cameraTransform, cameraTransformPreviousDraw
            matrix.copy torsoTransformToDraw, torsoTransformPreviousDraw
            pose.copy playerPoseNew, playerPoseOld
        
        matrix.interpolate entityTransformPreviousTick, entityTransform, progress, entityTransformToDraw
        matrix.interpolate torsoTransformPreviousTick, torsoTransform, progress, playerPoseNew.torso
        
        matrix.invert entityTransformToDraw, cameraTransform
        matrix.translate [0,-10, 10], cameraTransform
        
        matrix.applyToVector playerPoseNew.torso, [-1.5, -2.5, 0], start
        matrix.getX playerPoseNew.torso, xAxis
        ik.computeLimb start, leftFoot, 10, xAxis, playerPoseNew.legLeftUpper, playerPoseNew.legLeftLower
        
        matrix.applyToVector playerPoseNew.torso, [1.5, -2.5, 0], start
        ik.computeLimb start, rightFoot, 10, xAxis, playerPoseNew.legRightUpper, playerPoseNew.legRightLower

        matrix.getY playerPoseNew.torso, yAxis
        vector.negate xAxis, xAxis
        vector.interpolate xAxis, yAxis, 0.05, offset
        
        matrix.applyToVector playerPoseNew.torso, [-1.5, 4, 0], start
        vector.interpolate leftHandPreviousTick, leftHand, progress, leftHandToDraw
        ik.computeLimb start, leftHandToDraw, 10, offset, playerPoseNew.armLeftUpper, playerPoseNew.armLeftLower
        
        vector.negate yAxis, yAxis
        vector.interpolate xAxis, yAxis, 0.05, offset

        matrix.applyToVector playerPoseNew.torso, [1.5, 4, 0], start
        vector.interpolate rightHandPreviousTick, rightHand, progress, rightHandToDraw
        ik.computeLimb start, rightHandToDraw, 10, offset, playerPoseNew.armRightUpper, playerPoseNew.armRightLower
        
        matrix.copy playerPoseNew.torso, playerPoseNew.head
        matrix.translate [0, 6, 0], playerPoseNew.head, true
        matrix.rotateY (misc.interpolate headYawPreviousTick, headYaw, progress), playerPoseNew.head, true
        
        if firstDraw
            matrix.copy entityTransformToDraw, entityTransformPreviousDraw
            matrix.copy cameraTransform, cameraTransformPreviousDraw
            pose.copy playerPoseNew, playerPoseOld
            firstDraw = false
            
        context.begin 0, 0, context.width, context.height, 1, cameraTransformPreviousDraw, cameraTransform, 0.1, 0.5, 0.9
        cloud.draw testMap
        cloud.draw character, playerPoseOld, playerPoseNew
        
        return
        
    module.exports = { load, tick, draw }