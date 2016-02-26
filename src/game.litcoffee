# game

This module contains your game logic.  Its methods are called by the "index"
module to update the game state.

    gamepad = require "./input/gamepad.litcoffee"
    context = require "./rendering/context.litcoffee"
    track = require "./tracks/track.litcoffee"
    character = require "./characters/character.litcoffee"
    
    thirdPerson = require "./cameras/thirdPerson.litcoffee"
    
    cameraInstance = characterInstance = trackInstance = undefined
    
# load
Called before the first "tick"/"draw" to load any resources needed by the game.
Execute the argument when you have finished successfully.

    load = (callback) ->
        context.load()
        trackDefinition = require "./tracks/island/index.litcoffee"
        track.load trackDefinition, (_trackInstance) ->
            trackInstance = _trackInstance
            character.load (require "./characters/test/index.litcoffee"), trackDefinition.spawns[0], trackInstance, gamepad, (_characterInstance) ->
                characterInstance = _characterInstance
                cameraInstance = thirdPerson.create characterInstance.transform, 20, 10, 7, 0.3, 0.9
                callback()
    
# tick
Called at 20Hz to update game state.  Guaranteed to be called once between 
"load" and "draw".  May be called more or than once per call to "draw" or not at
all.

    tick = ->        
        track.tick trackInstance
        character.tick characterInstance
        thirdPerson.tick cameraInstance, characterInstance.triangle, 12
        return
  
# draw
Called with the progress through the current frame (a number between 0 and 1) to 
redraw the scene.
  
    draw = (progress) ->     
        track.preDraw trackInstance, progress
        character.preDraw characterInstance, progress
        thirdPerson.preDraw cameraInstance, progress
        context.begin 0, 0, context.width, context.height, 1, cameraInstance.transformPreviousDraw, cameraInstance.transform
        track.draw trackInstance, characterInstance.section
        character.draw characterInstance
        return
        
    module.exports = { load, tick, draw }