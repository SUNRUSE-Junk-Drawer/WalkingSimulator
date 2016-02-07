On calling with the path to a binary file and a callback, loads the image into
an ArrayBuffer, and calls the callback with an object as an argument containing:

- buffer: A WebGL ARRAY_BUFFER containing the ArrayBuffer.
- bytes: The number of bytes in the ArrayBuffer.
    
    context = require "./context.litcoffee"
    handleError = require "./../handleError.litcoffee"
    
    module.exports = (path, callback) ->
        request = new XMLHttpRequest()
        request.open "GET", path, true
        request.responseType = "arraybuffer"
        request.onreadystatechange = ->
            if request.readyState is 4
                if request.status is 200
                    gl = context.context
                    
                    buffer = gl.createBuffer()
                    gl.bindBuffer gl.ARRAY_BUFFER, buffer
                    gl.bufferData gl.ARRAY_BUFFER, request.response, gl.STATIC_DRAW
                    gl.bindBuffer gl.ARRAY_BUFFER, null
                    
                    callback
                        buffer: buffer
                        bytes: request.response.byteLength
                else
                    handleError "Failed to load binary file " + path
            return
        request.send null
        return