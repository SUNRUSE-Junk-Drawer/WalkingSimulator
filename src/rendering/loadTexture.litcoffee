On calling with the path to an image and a callback, loads the image into a 
WebGL texture, and calls the callback with:

- The WebGL texture.
    
    handleError = require "./../handleError.litcoffee"
    context = require "./context.litcoffee"
    
    module.exports = (path, callback) ->
        gl = context.context
        image = new Image()
        image.onload = ->
            texture = gl.createTexture()
            gl.bindTexture gl.TEXTURE_2D, texture
            gl.texImage2D gl.TEXTURE_2D, 0, gl.LUMINANCE, gl.LUMINANCE, gl.UNSIGNED_BYTE, image
            gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR
            gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR
            gl.bindTexture gl.TEXTURE_2D, null
            callback texture 
            return
        image.onerror = -> 
            handleError "Failed to load image " + path
            return
        image.src = path
        return