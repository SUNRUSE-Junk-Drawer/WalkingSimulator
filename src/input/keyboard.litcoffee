On calling, this sets up keyboard bindings based on the mappings in 
./keyboardMappings.

    gamepad = require "./gamepad.litcoffee"
    keyboardMappings = require "./keyboardMappings.litcoffee"

    module.exports = ->
        addEventListener "keydown", ->
            mapping = keyboardMappings[event.keyCode]
            if mapping then gamepad[mapping] = 1
            return
        addEventListener "keyup", ->
            mapping = keyboardMappings[event.keyCode]
            if mapping then gamepad[mapping] = 0
            return
        return