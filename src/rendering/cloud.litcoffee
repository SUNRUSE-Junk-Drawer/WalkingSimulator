Exports an object.
Call the "load" property once the context has been loaded to initialize required 
resources.
    
Call the "draw" property with a vertex buffer to draw it as a point cloud.  This
is required to be in the "MSC" format.

    context = require "./context.litcoffee"
    createProgram = require "./createProgram.litcoffee"
    loadTexture = require "./loadTexture.litcoffee"

    matrix = require "./../matrix.litcoffee"

The index buffer is shared between all point clouds and makes quadrilaterals
from triangle pairs.  It is regenerated larger if more points are required by a
new cloud.
    
    indexBuffer = undefined
    indexBufferSize = 0
    maximumIndices = Math.floor (65536 / 6)
    bytesPerVertex = 3 * 4 + 3 * 1 + 1 * 1 + 2 * 4

    program = undefined
    postScaleUniform = newTransformUniform = oldTransformUniform = undefined
    originAttribute = localAttribute = colorAttribute = undefined
    oldMatrixTemp = []
    newMatrixTemp = []
    
    texture = undefined
    
    module.exports = 
        load: (callback) ->
            gl = context.context

            indexBuffer = gl.createBuffer()
            gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, indexBuffer
            
            indices = []
            for i in [0...maximumIndices]
                indices[i * 6] = i * 4
                indices[i * 6 + 1] = i * 4 + 1
                indices[i * 6 + 2] = i * 4 + 2
                
                indices[i * 6 + 3] = i * 4 + 2
                indices[i * 6 + 4] = i * 4 + 3
                indices[i * 6 + 5] = i * 4

            gl.bufferData gl.ELEMENT_ARRAY_BUFFER, (new Uint16Array indices), gl.STATIC_DRAW
            gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, null
            
            program = createProgram (require "./cloud.vs"), (require "./cloud.fs")
            
            gl.useProgram program
            originAttribute = gl.getAttribLocation program, "origin"
            localAttribute = gl.getAttribLocation program, "local"
            colorAttribute = gl.getAttribLocation program, "color"
            postScaleUniform = gl.getUniformLocation program, "postScale"
            newTransformUniform = gl.getUniformLocation program, "newTransform"
            oldTransformUniform = gl.getUniformLocation program, "oldTransform"
            gl.useProgram null
            
            loadTexture (require "./noise.png"), (texture_) ->
                texture = texture_
                callback()
                return
            return
                
        draw: (instance, oldTransform, newTransform) ->
            gl = context.context
            gl.bindBuffer gl.ARRAY_BUFFER, instance.buffer
            gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, indexBuffer

            gl.enable gl.DEPTH_TEST
            gl.bindTexture gl.TEXTURE_2D, texture
            
            gl.useProgram program
            gl.enableVertexAttribArray originAttribute
            gl.enableVertexAttribArray localAttribute
            gl.enableVertexAttribArray colorAttribute
           
            if oldTransform
                matrix.multiply oldTransform, context.transforms[0], oldMatrixTemp
                matrix.multiply newTransform, context.transforms[1], newMatrixTemp
                
                gl.uniformMatrix4fv oldTransformUniform, false, oldMatrixTemp
                gl.uniformMatrix4fv newTransformUniform, false, newMatrixTemp
            else
                gl.uniformMatrix4fv oldTransformUniform, false, context.transforms[0]
                gl.uniformMatrix4fv newTransformUniform, false, context.transforms[1]
           
            gl.uniform2f postScaleUniform, context.postScale[0], context.postScale[1]
           
            points = instance.bytes / (4 * bytesPerVertex)
           
            for start in [0...points] by maximumIndices
                end = Math.min (start + maximumIndices), points
                
                gl.vertexAttribPointer originAttribute, 3, gl.FLOAT, false, bytesPerVertex, 4 * start * bytesPerVertex
                gl.vertexAttribPointer colorAttribute, 3, gl.UNSIGNED_BYTE, true, bytesPerVertex, 4 * start * bytesPerVertex + 3 * 4
                gl.vertexAttribPointer localAttribute, 2, gl.FLOAT, false, bytesPerVertex, 4 * start * bytesPerVertex + 3 * 4 + 3 * 1 + 1 * 1
                
                gl.drawElements gl.TRIANGLES, 6 * (end - start), gl.UNSIGNED_SHORT, 0
                
            gl.bindTexture gl.TEXTURE_2D, null
            gl.disableVertexAttribArray originAttribute
            gl.disableVertexAttribArray localAttribute
            gl.disableVertexAttribArray colorAttribute
            gl.useProgram null
            gl.disable gl.DEPTH_TEST
                
            return