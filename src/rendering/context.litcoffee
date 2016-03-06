Exports an object.
Call "load" early in the application to get the WebGL context.
The "context" property is the WebGL context.
The "width" and "height" properties are the dimensions of the viewport in pixels.

    handleError = require "./../handleError.litcoffee"
    matrix = require "./../matrix.litcoffee"

    module.exports =
        canvas: null
        context: null
        width: null
        height: null
        load: ->
            module.exports.canvas = (document.getElementsByTagName "canvas")[0]
            module.exports.context = module.exports.canvas.getContext "experimental-webgl", 
                antialias: false
                alpha: false
            if not module.exports.context then handleError "Failed to open a WebGL context"
            
            resize = ->
                module.exports.width = window.innerWidth
                module.exports.height = window.innerHeight
                if not module.exports.canvas then return
                module.exports.canvas.width = module.exports.width
                module.exports.canvas.height = module.exports.height
                return
                
            addEventListener "resize", resize
            resize()
            return
            
Call the "begin" property to set up the camera and viewport.  This takes the
following arguments:

- The distance, in pixels, between the left border of the screen and the
  left border of the viewport.
- The distance, in pixels, between the bottom border of the screen and the
  bottom border of the viewport.
- The width, in pixels, of the viewport.
- The height, in pixels, of the viewport.
- A zoom factor, where 1 is 100% and 2 is 200%.
- The matrix to apply to all geometry the previous frame.
- The matrix to apply to all geometry this frame.
            
        postScale: [1, 1]
        transforms: [[],[]]
            
        begin: (left, bottom, width, height, zoom, oldTransform, newTransform) ->
            gl = module.exports.context
            gl.viewport left, bottom, width, height
            gl.enable gl.SCISSOR_TEST
            gl.scissor left, bottom, width, height
            gl.clear gl.DEPTH_BUFFER_BIT
            gl.disable gl.SCISSOR_TEST
            
            matrix.copy oldTransform, module.exports.transforms[0]
            matrix.copy newTransform, module.exports.transforms[1]
            
            if width > height
                module.exports.postScale[0] = zoom * height / width
                module.exports.postScale[1] = zoom
            else
                module.exports.postScale[0] = zoom
                module.exports.postScale[1] = zoom * width / height
            return
            
Specific to this implementation are the following properties:
- "postScale": An array of two numbers to multiply the X and Y of every vertex
               by in NDC.  This is used to apply zoom and aspect correction.
- "transforms": An array of two matrices; the global transform from last frame
                and this frame.