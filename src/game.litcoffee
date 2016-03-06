# game

This module contains your game logic.  Its methods are called by the "index"
module to update the game state.

    context = require "./rendering/context.litcoffee"
    cloud = require "./rendering/cloud.litcoffee"
    cameraInstance = subway = undefined
    
    firstPerson = require "./cameras/firstPerson.litcoffee"
    navmesh = require "./navmesh.litcoffee"
    
# load
Called before the first "tick"/"draw" to load any resources needed by the game.
Execute the argument when you have finished successfully.

    load = (callback) ->
        context.load()
        navmesh.load (require "./map/navmesh.msn"), (_navmeshInstance) ->
            cameraInstance = firstPerson.create (require "./input/gamepad.litcoffee"), _navmeshInstance, [0, -16, 0], -0.2, -0.5, 0.6, 0.1, 0.09, 4
            cloud.load (require "./map/subway.msc"), (_subway) ->
                subway = _subway
                callback()
                return
            return
        return
    
# tick
Called at 20Hz to update game state.  Guaranteed to be called once between 
"load" and "draw".  May be called more or than once per call to "draw" or not at
all.

    tick = ->        
        firstPerson.tick cameraInstance
        return
  
# draw
Called with the progress through the current frame (a number between 0 and 1) to 
redraw the scene.
  
    draw = (progress) ->     
        firstPerson.preDraw cameraInstance, progress
        context.begin 0, 0, context.width, context.height, 1.8, cameraInstance.transform, cameraInstance.transformPreviousDraw
        cloud.draw subway
        return
        
    module.exports = { load, tick, draw }