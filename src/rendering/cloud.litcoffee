# cloud

Point clouds are stored as "MSC" (MasSplat Cloud) files.  The file structure is
binary, with the following fields repeated for each struct.

| Type    | Num. | Description                                          |
| ------- | ---- | ---------------------------------------------------- |
| float32 | 3    | The location of the origin in world space.  (XYZ)    |
| ubyte   | 3    | The intensities of the red, green and blue channels. |
| float32 | 1    | The radius of the splat.                             |

For skeletal point clouds, a companion .coffee file is generated exporting an
object containing:

- cloud: A "require" of the .msc file.
- bones: An array of objects describing the bones in the cloud, containing:

+ name: A string containing the object name in Blender.
+ splats: The number of splats in this bone.
+ transform: The transform applied to the object in Blender.

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

    programs = []
    oldMatrixTemp = []
    newMatrixTemp = []
    
    bytesPerVertex = 3 * 4 + 3 * 1 + 1 * 1 + 2 * 4
    
    texture = undefined
    
    ensureLoaded = (bones, callback) ->
        gl = context.context
        if not indexBuffer
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
            
        if not programs[bones]
            vertexShader = require "./cloud.vs"
            if bones > 1 then vertexShader = "#define BONES " + bones + "\n" + vertexShader
            program = createProgram vertexShader, (require "./cloud.fs")
            
            gl.useProgram program
            programs[bones] =
                program: program
                originAttribute: gl.getAttribLocation program, "origin"
                localAttribute: gl.getAttribLocation program, "local"
                colorAttribute: gl.getAttribLocation program, "color"
                postScaleUniform: gl.getUniformLocation program, "postScale"
                newTransformUniform: gl.getUniformLocation program, "newTransform"
                oldTransformUniform: gl.getUniformLocation program, "oldTransform"
                matrixBuffer: new Float32Array bones * 16
            programs[bones].matrices = (new Float32Array programs[bones].matrixBuffer.buffer, bone * 16 * 4, 16 for bone in [0...bones])
            if bones > 1
                programs[bones].boneAttribute = gl.getAttribLocation program, "bone"
            gl.useProgram null            
        
        if texture
            callback()
        else
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
        gl = context.context
        skeletal = typeof path isnt "string"
        ensureLoaded (if skeletal then path.bones.length else 1), ->
            file.arrayBuffer (if skeletal then path.cloud else path), (response) ->
                # The ArrayBuffer we get from the file is in the PLANAR format
                # as documented:  
                # Origin XYZ. (3xfloat)
                # Radius (float)
                # Color RGB. (3xubyte)
                # However, we need to reformat it a little; each splat needs
                # to become four vertices containing:
                # Origin XYZ. (3xfloat)
                # Color RGB. (3xubyte)
                # Bone ID. (ubyte)
                # Local XY. (2xfloat)
            
                splatCount = response.byteLength / (3 * 4 + 1 * 4 + 3 * 1)

                locations = new Float32Array response, 0, splatCount * 3
                radiuses = new Float32Array response, splatCount * 3 * 4, splatCount
                colors = new Uint8Array response, splatCount * (3 * 4 + 1 * 4), splatCount * 3
                
                arrayBuffer = new ArrayBuffer splatCount * bytesPerVertex * 4
                bufferFloats = new Float32Array arrayBuffer
                bufferBytes = new Uint8Array arrayBuffer
                
                boneSplats = boneId = 0
                
                for splat in [0...splatCount]
                    outputOffset = splat * (3 + 1 + 2) * 4
                    outputOffsetBytes = outputOffset * 4
                    
                    bufferFloats[outputOffset] = locations[splat * 3]
                    bufferFloats[outputOffset + 1] = locations[splat * 3 + 1]
                    bufferFloats[outputOffset + 2] = locations[splat * 3 + 2]
                    bufferBytes[outputOffsetBytes + 3 * 4] = colors[splat * 3]
                    bufferBytes[outputOffsetBytes + 3 * 4 + 1 * 1] = colors[splat * 3 + 1]
                    bufferBytes[outputOffsetBytes + 3 * 4 + 2 * 1] = colors[splat * 3 + 2]
                    bufferBytes[outputOffsetBytes + 3 * 4 + 3 * 1] = boneId
                    bufferFloats[outputOffset + 4] = -radiuses[splat]
                    bufferFloats[outputOffset + 5] = -radiuses[splat]

                    bufferFloats[outputOffset + 6] = locations[splat * 3]
                    bufferFloats[outputOffset + 7] = locations[splat * 3 + 1]
                    bufferFloats[outputOffset + 8] = locations[splat * 3 + 2]
                    bufferBytes[outputOffsetBytes + 9 * 4] = colors[splat * 3]
                    bufferBytes[outputOffsetBytes + 9 * 4 + 1 * 1] = colors[splat * 3 + 1]
                    bufferBytes[outputOffsetBytes + 9 * 4 + 2 * 1] = colors[splat * 3 + 2]
                    bufferBytes[outputOffsetBytes + 9 * 4 + 3 * 1] = boneId
                    bufferFloats[outputOffset + 10] = -radiuses[splat]
                    bufferFloats[outputOffset + 11] = radiuses[splat]
                    
                    bufferFloats[outputOffset + 12] = locations[splat * 3]
                    bufferFloats[outputOffset + 13] = locations[splat * 3 + 1]
                    bufferFloats[outputOffset + 14] = locations[splat * 3 + 2]
                    bufferBytes[outputOffsetBytes + 15 * 4] = colors[splat * 3]
                    bufferBytes[outputOffsetBytes + 15 * 4 + 1 * 1] = colors[splat * 3 + 1]
                    bufferBytes[outputOffsetBytes + 15 * 4 + 2 * 1] = colors[splat * 3 + 2]
                    bufferBytes[outputOffsetBytes + 15 * 4 + 3 * 1] = boneId
                    bufferFloats[outputOffset + 16] = radiuses[splat]
                    bufferFloats[outputOffset + 17] = radiuses[splat]
                    
                    bufferFloats[outputOffset + 18] = locations[splat * 3]
                    bufferFloats[outputOffset + 19] = locations[splat * 3 + 1]
                    bufferFloats[outputOffset + 20] = locations[splat * 3 + 2]
                    bufferBytes[outputOffsetBytes + 21 * 4] = colors[splat * 3]
                    bufferBytes[outputOffsetBytes + 21 * 4 + 1 * 1] = colors[splat * 3 + 1]
                    bufferBytes[outputOffsetBytes + 21 * 4 + 2 * 1] = colors[splat * 3 + 2]
                    bufferBytes[outputOffsetBytes + 21 * 4 + 3 * 1] = boneId
                    bufferFloats[outputOffset + 22] = radiuses[splat]
                    bufferFloats[outputOffset + 23] = -radiuses[splat]
                    
                    if skeletal     
                        boneSplats++
                        if boneSplats is path.bones[boneId].splats
                            boneSplats = 0
                            boneId++
                
                buffer = gl.createBuffer()
                gl.bindBuffer gl.ARRAY_BUFFER, buffer
                gl.bufferData gl.ARRAY_BUFFER, arrayBuffer, gl.STATIC_DRAW
                gl.bindBuffer gl.ARRAY_BUFFER, null
                
                argument = { buffer, splatCount }
                if skeletal then argument.skeleton = path
                callback argument
                return
            return
        return
        
## draw

- A drawable point cloud instance.

The following are optional, but must be given together if either is given:

- The matrix or pose applied last frame.
- The matrix or pose to apply this frame.
                
    draw = (instance, oldTransform, newTransform) ->
        bones = 1
        if instance.skeleton then bones = instance.skeleton.bones.length
        program = programs[bones]
    
        gl = context.context
        gl.bindBuffer gl.ARRAY_BUFFER, instance.buffer
        gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, indexBuffer

        gl.enable gl.DEPTH_TEST
        gl.bindTexture gl.TEXTURE_2D, texture
        
        gl.useProgram program.program
        gl.enableVertexAttribArray program.originAttribute
        gl.enableVertexAttribArray program.localAttribute
        if bones > 1 then gl.enableVertexAttribArray program.boneAttribute
        gl.enableVertexAttribArray program.colorAttribute
       
        if instance.skeleton
            if not oldTransform then throw new Error "A pose is required when using a skeletal point cloud"
            temp = []
            matrix.identity temp
            matrix.translate [5, 0, 0], temp
            for bone, boneId in instance.skeleton.bones
                matrix.multiply oldTransform[bone.name], context.transforms[0], program.matrices[boneId]
            gl.uniformMatrix4fv program.oldTransformUniform, false, program.matrixBuffer
            for bone, boneId in instance.skeleton.bones
                matrix.multiply newTransform[bone.name], context.transforms[1], program.matrices[boneId]
            gl.uniformMatrix4fv program.newTransformUniform, false, program.matrixBuffer
        else
            if oldTransform
                matrix.multiply oldTransform, context.transforms[0], oldMatrixTemp
                matrix.multiply newTransform, context.transforms[1], newMatrixTemp
                
                gl.uniformMatrix4fv program.oldTransformUniform, false, oldMatrixTemp
                gl.uniformMatrix4fv program.newTransformUniform, false, newMatrixTemp
            else
                gl.uniformMatrix4fv program.oldTransformUniform, false, context.transforms[0]
                gl.uniformMatrix4fv program.newTransformUniform, false, context.transforms[1]
                        
        gl.uniform2f program.postScaleUniform, context.postScale[0], context.postScale[1]
       
        for start in [0...instance.splatCount] by maximumIndices
            end = Math.min (start + maximumIndices), instance.splatCount
            
            gl.vertexAttribPointer program.originAttribute, 3, gl.FLOAT, false, bytesPerVertex, 4 * start * bytesPerVertex
            gl.vertexAttribPointer program.colorAttribute, 3, gl.UNSIGNED_BYTE, true, bytesPerVertex, 4 * start * bytesPerVertex + 3 * 4
            if bones > 1 then gl.vertexAttribPointer program.boneAttribute, 1, gl.UNSIGNED_BYTE, false, bytesPerVertex, 4 * start * bytesPerVertex + 3 * 4 + 3 * 1
            gl.vertexAttribPointer program.localAttribute, 2, gl.FLOAT, false, bytesPerVertex, 4 * start * bytesPerVertex + 3 * 4 + 3 * 1 + 1 * 1
            
            gl.drawElements gl.TRIANGLES, 6 * (end - start), gl.UNSIGNED_SHORT, 0
            
        gl.bindTexture gl.TEXTURE_2D, null
        gl.disableVertexAttribArray program.originAttribute
        gl.disableVertexAttribArray program.localAttribute
        if bones > 1 then gl.disableVertexAttribArray program.boneAttribute
        gl.disableVertexAttribArray program.colorAttribute
        gl.useProgram null
        gl.disable gl.DEPTH_TEST
            
        return
            
    module.exports = { load, draw }