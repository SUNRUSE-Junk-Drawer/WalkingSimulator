# geometry

Vertex-coloured, triangulated geometry is stored as "MSG" (MasSplat Geometry) 
files.  It is indexed, allowing for up to 65535 triangles joining up to 65535
unique location/colour pairs.  (vertices)  The file structure is binary, 
containing:

| Type    | Num.              | Description                                                |
| ------- | ----------------- | ---------------------------------------------------------- |
| uint16  | 1                 | The number of vertices defined.                            |
| uint16  | 1                 | The number of triangles defined.                           |
| float32 | 3x num. vertices  | The X, Y and Z of each vertex.                             |
| ubyte   | 3x num. vertices  | The R, G and B of each vertex.                             |
| uint16  | 3x num. triangles | The first, second and third vertex index of each triangle. |

3D space is defined as:

- x: left to right
- y: bottom to top
- z: back to front

## load

- filename: The "real" location of the MSG file to load.  (i.e. already 
            "require"-d)
- callback: Called with a drawable geometry instance on successful loading.

    context = require "./context.litcoffee"
    createProgram = require "./createProgram.litcoffee"
    file = require "./../file.litcoffee"
    matrix = require "./../matrix.litcoffee"
    
    locationAttribute = colorAttribute = postScaleUniform = transformUniform = program = undefined

    load = (filename, callback) ->
        gl = context.context
    
        if not program
            program = createProgram (require "./geometry.vs"), (require "./geometry.fs")
            locationAttribute = gl.getAttribLocation program, "location"
            colorAttribute = gl.getAttribLocation program, "color"
            postScaleUniform = gl.getUniformLocation program, "postScale"
            transformUniform = gl.getUniformLocation program, "transform"
            
        file.arrayBuffer filename, (response) ->
            header = new Uint16Array response, 0, 2 
            vertexData = new Uint8Array response, 4, header[0] * (3 * 4 + 3 * 1)
            indices = new Uint8Array response, 4 + header[0] * (3 * 4 + 3 * 1), header[1] * 3 * 2
            
            indexBuffer = gl.createBuffer()
            gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, indexBuffer
            gl.bufferData gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW
            gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, null
            
            vertexBuffer = gl.createBuffer()
            gl.bindBuffer gl.ARRAY_BUFFER, vertexBuffer
            gl.bufferData gl.ARRAY_BUFFER, vertexData, gl.STATIC_DRAW
            gl.bindBuffer gl.ARRAY_BUFFER, null
            
            callback 
                indexBuffer: indexBuffer
                vertexBuffer: vertexBuffer
                vertices: header[0]
                indices: header[1] * 3
            return
        return
    
## draw

- A drawable geometry instance.
- Optionally, a matrix to apply.

    matrixTemp = []

    draw = (instance, transform) ->
        gl = context.context
    
        gl = context.context
        gl.bindBuffer gl.ARRAY_BUFFER, instance.vertexBuffer
        gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, instance.indexBuffer

        gl.enable gl.DEPTH_TEST
        
        gl.useProgram program
        gl.enableVertexAttribArray locationAttribute
        gl.enableVertexAttribArray colorAttribute
       
        if transform
            matrix.multiply transform, context.transforms[1], matrixTemp
            
            gl.uniformMatrix4fv transformUniform, false, matrixTemp
        else
            gl.uniformMatrix4fv transformUniform, false, context.transforms[1]
                        
        gl.uniform2f postScaleUniform, context.postScale[0], context.postScale[1]    
        gl.vertexAttribPointer locationAttribute, 3, gl.FLOAT, false, 0, 0
        gl.vertexAttribPointer colorAttribute, 3, gl.UNSIGNED_BYTE, true, 0, instance.vertices * (3 * 4)
        gl.drawElements gl.TRIANGLES, instance.indices, gl.UNSIGNED_SHORT, 0
        gl.disableVertexAttribArray locationAttribute
        gl.disableVertexAttribArray colorAttribute
        gl.bindBuffer gl.ARRAY_BUFFER, null
        gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, null
        gl.useProgram null
        gl.disable gl.DEPTH_TEST
        return

    module.exports = { load, draw }