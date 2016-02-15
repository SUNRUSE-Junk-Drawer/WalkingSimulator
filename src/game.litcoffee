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
       
    triangle = undefined
    
    testEntity = testMap = testNavmesh = undefined

# load
Called before the first "tick"/"draw" to load any resources needed by the game.
Execute the argument when you have finished successfully.

    load = (callback) ->
        keyboard()
        context.load()
        cloud.load (require "./testEntity.msc"), (testEntity_) ->
            testEntity = testEntity_
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

    surfaceCorrectedEntityTransform = []
    matrix.identity surfaceCorrectedEntityTransform

    cameraTransform = []
    cameraTransformPreviousDraw = []
    matrix.identity cameraTransform

    velocity = [0, 0, 0]    
    xAxis = []
    yAxis = []
    zAxis = []
    translation = []
    acceleration = []
    forwardVelocity = []
    sidewardVelocity = []
    
    tick = ->    
        if not firstTick
            matrix.copy entityTransform, entityTransformPreviousTick
            
        matrix.translate velocity, entityTransform        
        
        # Left/right rotation.
        matrix.rotateY ((gamepad.left - gamepad.right) * 0.1), entityTransform, true
        
        # Apply navmesh triangle collision.
        matrix.getTranslation entityTransform, translation
        triangle = navmesh.constrain translation, triangle
        
        # Gravity.
        velocity[1] -= 0.2
        
        # Forwards/backwards movement.
        matrix.getZ entityTransform, zAxis
        
        # Determine if we're underground.
        altitude = plane.distance triangle.plane, translation
        
        if altitude < 0
            velocity = velocity
            plane.project triangle.plane, translation, translation
            
            # Reflecting the velocity against the hit surface but then 
            # flattening it has the effect that hitting a ramp bounces you up it
            # but you don't bounce when falling onto the floor.
            vector.reflect velocity, triangle.plane.normal, velocity
            vector.flatten velocity, triangle.plane.normal, velocity
        
            vector.multiply.byScalar zAxis, ((gamepad.forward - gamepad.backward) * 0.2), acceleration
            vector.add.vector velocity, acceleration, velocity
        
            # Apply friction.  There is more sidewards than backwards/forwards.
            vector.flatten velocity, zAxis, sidewardVelocity
            vector.straighten velocity, zAxis, forwardVelocity
            vector.multiply.byScalar sidewardVelocity, 0.9, sidewardVelocity
            vector.multiply.byScalar forwardVelocity, 0.99, forwardVelocity
            vector.add.vector sidewardVelocity, forwardVelocity, velocity
            
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
    
        if firstTick
            matrix.copy entityTransform, entityTransformPreviousTick
            firstTick = false
        return
  
# draw
Called with the progress through the current frame (a number between 0 and 1) to 
redraw the scene.
  
    draw = (progress) ->     
        if not firstDraw
            matrix.copy entityTransformToDraw, entityTransformPreviousDraw
            matrix.copy cameraTransform, cameraTransformPreviousDraw
        
        matrix.interpolate entityTransformPreviousTick, entityTransform, progress, entityTransformToDraw
        
        matrix.invert entityTransformToDraw, cameraTransform
        matrix.translate [0,-10, 10], cameraTransform
        
        if firstDraw
            matrix.copy entityTransformToDraw, entityTransformPreviousDraw
            matrix.copy cameraTransform, cameraTransformPreviousDraw
            firstDraw = false
            
        context.begin 0, 0, context.width, context.height, 1, cameraTransformPreviousDraw, cameraTransform, 0.1, 0.5, 0.9
        cloud.draw testMap
        cloud.draw testEntity, entityTransformPreviousDraw, entityTransformToDraw
        
        return
        
    module.exports = { load, tick, draw }