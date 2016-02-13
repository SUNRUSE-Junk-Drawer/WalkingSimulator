On calling with the path to a binary file and a callback, loads the image into
an ArrayBuffer, and calls the callback with an object as an argument containing:

- buffer: A WebGL ARRAY_BUFFER containing the ArrayBuffer.
- bytes: The number of bytes in the ArrayBuffer.
    
    context = require "./context.litcoffee"
    file = require "./../file.litcoffee"
    
    module.exports = (path, callback) ->
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
            
            arrayBuffer = new ArrayBuffer splatCount * (3 * 4 + 3 * 1 + 1 * 1 + 2 * 4) * 4
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
            
            callback
                buffer: buffer
                bytes: arrayBuffer.byteLength
                
            return
        return