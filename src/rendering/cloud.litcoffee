# cloud

Point clouds are stored as "MSC" (MasSplat Cloud) files.  The file structure is
binary, with the following fields repeated for each struct.

| Type    | Num. | Description                                          |
| ------- | ---- | ---------------------------------------------------- |
| float32 | 3    | The location of the origin in world space.  (XYZ)    |
| ubyte   | 3    | The intensities of the red, green and blue channels. |
| ubyte   | 1    | In animated clouds, a bone ID.  Otherwise, padding.  |
| float32 | 1    | The radius of the splat.                             |

3D space is defined as:

- x: left to right
- y: bottom to top
- z: back to front

    context = require "./context.litcoffee"
    createProgram = require "./createProgram.litcoffee"
    loadTexture = require "./loadTexture.litcoffee"
    file = require "./../file.litcoffee"

    matrix = require "./../matrix.litcoffee"
    
    indexBuffer = undefined
    indexBufferSize = 0
    maximumIndices = Math.floor (65536 / 6)

    program = undefined
    postScaleUniform = newTransformUniform = oldTransformUniform = undefined
    originAttribute = localAttribute = colorAttribute = undefined
    oldMatrixTemp = []
    newMatrixTemp = []
    
    bytesPerVertex = 3 * 4 + 3 * 1 + 1 * 1 + 2 * 4
    
    texture = undefined
    
    ensureLoaded = (callback) ->
        if texture
            callback()
        else
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
        
## load

- filename: The "real" location of the MSC file to load.  (i.e. already 
            "require"-d)
- callback: Called with a drawable point cloud instance on successful loading.

The first load may take longer as textures are downloaded and shaders compiled.
    
    load = (path, callback) ->
        ensureLoaded ->
            file.arrayBuffer path, (response) ->
                # The ArrayBuffer we get from the file is in the format
                # as documented:  
                # Origin XYZ. (3xfloat)
                # Color RGB. (3xubyte)
                # Bone ID.  (ubyte)
                # Radius (float)
                # However, we need to reformat it a little; each splat needs
                # to become four vertices containing:
                # Origin XYZ. (3xfloat)
                # Color RGB. (3xubyte)
                # Bone ID. (ubyte)
                # Local XY. (2xfloat)
            
                splatCount = response.byteLength / (3 * 4 + 3 * 1 + 1 * 1 + 1 * 4)

                inputFloats = new Float32Array response
                inputBytes = new Uint8Array response
                
                arrayBuffer = new ArrayBuffer splatCount * bytesPerVertex * 4
                bufferFloats = new Float32Array arrayBuffer
                bufferBytes = new Uint8Array arrayBuffer
                
                for splat in [0...splatCount]
                    inputOffset = splat * (3 + 1 + 1)
                    inputOffsetBytes = inputOffset * 4
                    outputOffset = splat * (3 + 1 + 2) * 4
                    outputOffsetBytes = outputOffset * 4
                    
                    bufferFloats[outputOffset] = inputFloats[inputOffset]
                    bufferFloats[outputOffset + 1] = inputFloats[inputOffset + 1]
                    bufferFloats[outputOffset + 2] = inputFloats[inputOffset + 2]
                    bufferBytes[outputOffsetBytes + 3 * 4] = inputBytes[inputOffsetBytes + 3 * 4]
                    bufferBytes[outputOffsetBytes + 3 * 4 + 1 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 1 * 1]
                    bufferBytes[outputOffsetBytes + 3 * 4 + 2 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 2 * 1]
                    bufferBytes[outputOffsetBytes + 3 * 4 + 3 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 3 * 1]                        
                    bufferFloats[outputOffset + 4] = -inputFloats[inputOffset + 4]
                    bufferFloats[outputOffset + 5] = -inputFloats[inputOffset + 4]

                    bufferFloats[outputOffset + 6] = inputFloats[inputOffset]
                    bufferFloats[outputOffset + 7] = inputFloats[inputOffset + 1]
                    bufferFloats[outputOffset + 8] = inputFloats[inputOffset + 2]
                    bufferBytes[outputOffsetBytes + 9 * 4] = inputBytes[inputOffsetBytes + 3 * 4]
                    bufferBytes[outputOffsetBytes + 9 * 4 + 1 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 1 * 1]
                    bufferBytes[outputOffsetBytes + 9 * 4 + 2 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 2 * 1]
                    bufferBytes[outputOffsetBytes + 9 * 4 + 3 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 3 * 1]
                    bufferFloats[outputOffset + 10] = -inputFloats[inputOffset + 4]
                    bufferFloats[outputOffset + 11] = inputFloats[inputOffset + 4]
                    
                    bufferFloats[outputOffset + 12] = inputFloats[inputOffset]
                    bufferFloats[outputOffset + 13] = inputFloats[inputOffset + 1]
                    bufferFloats[outputOffset + 14] = inputFloats[inputOffset + 2]
                    bufferBytes[outputOffsetBytes + 15 * 4] = inputBytes[inputOffsetBytes + 3 * 4]
                    bufferBytes[outputOffsetBytes + 15 * 4 + 1 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 1 * 1]
                    bufferBytes[outputOffsetBytes + 15 * 4 + 2 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 2 * 1]
                    bufferBytes[outputOffsetBytes + 15 * 4 + 3 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 3 * 1]
                    bufferFloats[outputOffset + 16] = inputFloats[inputOffset + 4]
                    bufferFloats[outputOffset + 17] = inputFloats[inputOffset + 4]
                    
                    bufferFloats[outputOffset + 18] = inputFloats[inputOffset]
                    bufferFloats[outputOffset + 19] = inputFloats[inputOffset + 1]
                    bufferFloats[outputOffset + 20] = inputFloats[inputOffset + 2]
                    bufferBytes[outputOffsetBytes + 21 * 4] = inputBytes[inputOffsetBytes + 3 * 4]
                    bufferBytes[outputOffsetBytes + 21 * 4 + 1 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 1 * 1]
                    bufferBytes[outputOffsetBytes + 21 * 4 + 2 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 2 * 1]
                    bufferBytes[outputOffsetBytes + 21 * 4 + 3 * 1] = inputBytes[inputOffsetBytes + 3 * 4 + 3 * 1]
                    bufferFloats[outputOffset + 22] = inputFloats[inputOffset + 4]
                    bufferFloats[outputOffset + 23] = -inputFloats[inputOffset + 4]
                    
                gl = context.context
                
                buffer = gl.createBuffer()
                gl.bindBuffer gl.ARRAY_BUFFER, buffer
                gl.bufferData gl.ARRAY_BUFFER, arrayBuffer, gl.STATIC_DRAW
                gl.bindBuffer gl.ARRAY_BUFFER, null
                
                callback { buffer, splatCount }
                return
            return
        return
        
## draw

- A drawable point cloud instance.

The following are optional, but must be given together if either is given:

- The matrix applied last frame.
- The matrix to apply this frame.
                
    draw = (instance, oldTransform, newTransform) ->
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
       
        for start in [0...instance.splatCount] by maximumIndices
            end = Math.min (start + maximumIndices), instance.splatCount
            
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
            
    module.exports = { load, draw }