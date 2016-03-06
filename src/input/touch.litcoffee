On calling, this sets up touch bindings for any "touchpad" elements.

    gamepad = require "./gamepad.litcoffee"

    touchpads = undefined

    module.exports =
        load: ->
            touchpads = for element in document.getElementsByTagName "touchpad"
                element: element
                button: element.getAttribute "button"
                type: element.getAttribute "type"
                up: element.getAttribute "up"
                down: element.getAttribute "down"
                left: element.getAttribute "left"
                right: element.getAttribute "right"
                touchIdentifier: null

            addEventListener "touchstart", (event) ->
                for touch in event.changedTouches
                    for touchpad in touchpads
                        if touchpad.element isnt touch.target then continue
                        touchpad.touchIdentifier = touch.identifier
                        touchpad.latestX = touchpad.startedX = touchpad.lastX = touch.clientX
                        touchpad.latestY = touchpad.startedY = touchpad.lastY = touch.clientY
                        if touchpad.button then gamepad[touchpad.button] = 1
                return

            addEventListener "touchmove", (event) ->
                scale = Math.min window.innerWidth, window.innerHeight
                for touch in event.touches
                    for touchpad in touchpads
                        if touchpad.touchIdentifier isnt touch.identifier then continue
                        touchpad.latestX = touch.clientX
                        touchpad.latestY = touch.clientY
                        switch touchpad.type
                            when "mouse"
                                if touchpad.left then gamepad[touchpad.left] = -15 * Math.min 0, (touchpad.latestX - touchpad.lastX) / scale
                                if touchpad.right then gamepad[touchpad.right] = 15 * Math.max 0, (touchpad.latestX - touchpad.lastX) / scale
                                if touchpad.up then gamepad[touchpad.up] = -15 * Math.max 0, (touchpad.latestY - touchpad.lastY) / scale
                                if touchpad.down then gamepad[touchpad.down] = 15 * Math.min 0, (touchpad.latestY - touchpad.lastY) / scale
                            when "joystick"
                                if touchpad.left then gamepad[touchpad.left] = -3 * Math.max 0, (touchpad.latestX - touchpad.startedX) / scale
                                if touchpad.right then gamepad[touchpad.right] = 3 * Math.min 0, (touchpad.latestX - touchpad.startedX) / scale
                                if touchpad.up then gamepad[touchpad.up] = -3 * Math.max 0, (touchpad.latestY - touchpad.startedY) / scale
                                if touchpad.down then gamepad[touchpad.down] = 3 * Math.min 0, (touchpad.latestY - touchpad.startedY) / scale
                return

            addEventListener "touchend", (event) ->
                for touch in event.changedTouches
                    for touchpad in touchpads
                        if touchpad.touchIdentifier isnt touch.identifier then continue
                        if touchpad.left then gamepad[touchpad.left] = 0
                        if touchpad.right then gamepad[touchpad.right] = 0
                        if touchpad.up then gamepad[touchpad.up] = 0
                        if touchpad.down then gamepad[touchpad.down] = 0
                        if touchpad.button then gamepad[touchpad.button] = 0
                        touchpad.touchIdentifier = null
                return
            return

        tick: ->
            for touchpad in touchpads
                touchpad.lastX = touchpad.latestX
                touchpad.lastY = touchpad.latestY
                if touchpad.type is "mouse" and touchpad.touchIdentifier isnt null
                    if touchpad.left then gamepad[touchpad.left] = 0
                    if touchpad.right then gamepad[touchpad.right] = 0
                    if touchpad.up then gamepad[touchpad.up] = 0
                    if touchpad.down then gamepad[touchpad.down] = 0
            return