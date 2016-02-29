# game

This module contains your game logic.  Its methods are called by the "index"
module to update the game state.

    context = require "./rendering/context.litcoffee"
    
# load
Called before the first "tick"/"draw" to load any resources needed by the game.
Execute the argument when you have finished successfully.

    load = (callback) ->
        context.load()
        callback()
        return
    
# tick
Called at 20Hz to update game state.  Guaranteed to be called once between 
"load" and "draw".  May be called more or than once per call to "draw" or not at
all.

    tick = ->        
        return
  
# draw
Called with the progress through the current frame (a number between 0 and 1) to 
redraw the scene.
  
    draw = (progress) ->     
        return
        
    module.exports = { load, tick, draw }