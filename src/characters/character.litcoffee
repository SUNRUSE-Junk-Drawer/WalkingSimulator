# character

A character definition is an object containing:

- cloud: A skeletal cloud module to display for the character.  This should
         include the bones "torso" and "head".
- torsoHeight: A number specifying how much distance should be between the torso
               and the ground when on it.
- turnSpeed: A number specifying how many radians per tick the character can 
             yaw.
- runSpeed: A number specifying how quickly the character can accelerate 
            forward and backward.
- strafeSpeed: A number specifying how quickly the character can accelerate left
               and right.
- airResistance: A number specifying a constant damping applied to velocity to
                 simulate air resistance.  0 stops dead, 1 applies no air
                 resistance.
- rotationSpeed: A number specifying how quickly the character rotates to match
                 the surface on which it stands.  0 is not at all, and 1 is 
                 instantly snapping to it.
- gravity: A number specifying how strongly gravity affects the character.
- slopeTolerance: A number, where "1" means even the slightest incline moves the
                  character, while at "0" nothing short of a vertical wall does.

A character instance is an object containing:

- definition: A reference to the character definition this instance was created
              from.
- transform: A matrix defining the overall transform of the character; 
             positioned at their feet, oriented to the navmesh''s surface and
             looking in the same direction as the character.
- triangle: The navmesh triangle currently containing the character.
- section: A string specifying the name of the section currently containing the
           character.

    cloud = require "./../rendering/cloud.litcoffee"
    pose = require "./../pose.litcoffee"
    matrix = require "./../matrix.litcoffee"
    vector = require "./../vector.litcoffee"
    plane = require "./../plane.litcoffee"
    ik = require "./../ik.litcoffee"
    navmesh = require "./../navmesh.litcoffee"

## load 

- A character definition.
- A track definition spawn to spawn at.
- The track instance in use.
- An object equivalent to the "gamepad" module.
- A callback to execute on success with the character instance as an argument on
  success.

Returns a new character instance.

    location = []

    load = (characterDefinition, spawn, trackInstance, gamepad, callback) ->        
        cloud.load characterDefinition.cloud, (cloudInstance) ->        
            transform = []
            transformPreviousTick = []
            matrix.copy spawn.transform, transform
            matrix.copy spawn.transform, transformPreviousTick
            
            matrix.getTranslation transform, location
            
            poseNew = pose.create characterDefinition.cloud
            poseOld = pose.create characterDefinition.cloud
        
            callback
                definition: characterDefinition
                gamepad: gamepad
                transform: transform
                transformPreviousTick: transformPreviousTick
                transformToDraw: []
                transformPreviousDraw: []
                pose: poseNew
                posePreviousDraw: poseOld
                velocity: [0, 0, 0]
                cloudInstance: cloudInstance
                trackInstance: trackInstance
                firstDraw: true
                triangle: navmesh.findNearest trackInstance.navmesh, location
                section: spawn.section
            return
        return

## tick

- A character instance.

    forwardAxis = []
    rightAxis = []
    upAxis = []
    velocityChange = []
    targetVelocity = []
    conformed = []

    tick = (instance) ->
        if not instance.firstTick
            matrix.copy instance.transform, instance.transformPreviousTick

        matrix.getTranslation instance.transform, location
        vector.add.vector location, instance.velocity, location
        
        instance.triangle = navmesh.constrain location, instance.triangle, (edge) ->
            vector.reflect instance.velocity, edge.plane.normal, instance.velocity
            vector.flatten instance.velocity, edge.plane.normal, instance.velocity
            return
        
        # Determine if we are on the ground.
        altitude = plane.distance instance.triangle.plane, location
        if altitude < 0.001
            plane.project instance.triangle.plane, location, location
            vector.reflect instance.velocity, instance.triangle.plane.normal, instance.velocity
            vector.flatten instance.velocity, instance.triangle.plane.normal, instance.velocity
            
            matrix.getX instance.transform, rightAxis
            matrix.getY instance.transform, upAxis
            matrix.getZ instance.transform, forwardAxis
            
            vector.multiply.byScalar rightAxis, (instance.gamepad.right - instance.gamepad.left) * instance.definition.strafeSpeed, targetVelocity
            vector.multiply.byScalar forwardAxis, (instance.gamepad.forward - instance.gamepad.backward) * instance.definition.runSpeed, velocityChange
            vector.add.vector targetVelocity, velocityChange, targetVelocity

            mag = vector.magnitude targetVelocity
            if mag > 1
                vector.divide.byScalar targetVelocity, mag, targetVelocity
                mag = 1   
            vector.add.vector instance.velocity, targetVelocity, instance.velocity
            
            # Gravity barely has any effect on the flat, but ramps up to full
            # power on a wall.
            gravityEffect = Math.max 0, (instance.definition.slopeTolerance - (instance.triangle.plane.normal[1] / instance.definition.slopeTolerance))
            instance.velocity[1] -= instance.definition.gravity * gravityEffect
            
        else
            instance.velocity[1] -= instance.definition.gravity
        
        matrix.rotateY (instance.gamepad.left - instance.gamepad.right) * instance.definition.turnSpeed, instance.transform, true
        
        vector.multiply.byScalar instance.velocity, instance.definition.airResistance, instance.velocity
            
        matrix.setTranslation location, instance.transform
        
        # If we're moving slowly, keep pointing where we already are.
        # If we're moving a little quicker, turn to point where we are going.       
        if ((vector.magnitude instance.velocity) - (Math.abs vector.dot instance.velocity, upAxis)) > 1
            vector.copy instance.velocity, forwardAxis
        else
            matrix.getZ instance.transform, forwardAxis
        
        # Attempt to track the surface by orienting our Y/up axis with the plane
        # of the navmesh triangle.
        vector.flatten forwardAxis, instance.triangle.plane.normal, forwardAxis
        vector.cross instance.triangle.plane.normal, forwardAxis, rightAxis
        vector.cross rightAxis, instance.triangle.plane.normal, forwardAxis
        vector.normalize rightAxis, rightAxis
        vector.normalize forwardAxis, forwardAxis
        matrix.copy instance.transform, conformed
        matrix.setX rightAxis, conformed
        matrix.setY instance.triangle.plane.normal, conformed
        matrix.setZ forwardAxis, conformed
        matrix.interpolate instance.transform, conformed, instance.definition.rotationSpeed, instance.transform
            
        if instance.firstTick
            matrix.copy instance.transform, instance.transformPreviousTick
            instance.firstTick = false
    
        return
    
## preDraw

- A character instance.
- The progress through the current frame, where 0 is the start and 1 is the end.

This should be called once per draw frame, before calling "draw" for this 
character instance.

    transformInterpolated = []
    torsoLocation = [0, 0, 0]

    preDraw = (instance, progress) ->
        if not instance.firstDraw
            pose.copy instance.pose, instance.posePreviousDraw
            
        matrix.interpolate instance.transformPreviousTick, instance.transform, progress, transformInterpolated
        matrix.copy transformInterpolated, instance.pose.torso
        torsoLocation[1] = instance.definition.torsoHeight
        matrix.translate torsoLocation, instance.pose.torso, true
        
        if instance.firstDraw
            pose.copy instance.pose, instance.posePreviousDraw
            instance.firstDraw = false
            
        return

## draw

- A character instance.

This can be called multiple times per frame to draw the character in multiple
viewports.  Call "preDraw" first.

    draw = (character) ->
        cloud.draw character.cloudInstance, character.posePreviousDraw, character.pose
        return

    module.exports = { load, tick, preDraw, draw }