    context = require "./rendering/context.litcoffee"
    cloud = require "./rendering/cloud.litcoffee"
    matrix = require "./matrix.litcoffee"
    misc = require "./misc.litcoffee"
    loadVertices = require "./rendering/loadVertices.litcoffee"

    identity = []
    matrix.identity identity
    matrix.translate -150, -20, -150, identity
    
    oldTransform = []
    newTransform = []
    
    turned = oldTurned = 0

    testMap = undefined

    module.exports = 

Call the "load" property to initialize the game.

    load: (callback) ->
        context.load()
        cloud.load ->
            loadVertices (require "./testMap.msc"), (testMap_) ->
                testMap = testMap_
                callback()
                return
            return
        return
    
Call the "tick" property at 20Hz to update game state.
    
    tick: ->
        oldTurned = turned
        turned += 0.05
        return
  
Call the "draw" property with the progress through the current frame in 0...1
space to render the game.
  
    draw: (progress) ->     
        matrix.copy newTransform, oldTransform
        matrix.identity newTransform
        matrix.rotateY (misc.interpolate oldTurned, turned, progress), newTransform
        matrix.translate 50, 0, 0, newTransform
        context.begin 0, 0, context.width, context.height, 1, oldTransform, newTransform, 0.1, 0.5, 0.9
        cloud.draw testMap, identity, identity
        return