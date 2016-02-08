On calling with the path to a MSN file and a callback, reads the MSN file and
executes the callback with an object as the argument.
    
    handleError = require "./handleError.litcoffee"
    
    module.exports = (path, callback) ->
        request = new XMLHttpRequest()
        request.open "GET", path, true
        request.responseType = "arraybuffer"
        request.onreadystatechange = ->
            if request.readyState is 4
                if request.status is 200
                    triangles = request.response.byteLength / (3 * 3 * 4 + 3 * 4 + 3 * 3 * 4 + 3 * 2)
                
                    vertices = for vertex in [0...3]
                        for axis in [0...3]
                            new Float32Array request.response, (vertex * 3 + axis) * 4 * triangles, triangles
                    
                    normals = for axis in [0...3]
                        new Float32Array request.response, (3 * 3 + axis) * 4 * triangles, triangles
                    
                    edgeNormals = for edge in [0...3]
                        for axis in [0...3]
                            new Float32Array request.response, (3 * 3 + 3 + edge * 3 + axis) * 4 * triangles, triangles

                    neighbors = for edge in [0...3]
                        new Uint16Array request.response, ((3 * 3 + 3 + 3 * 3) * 4 + edge * 2) * triangles, triangles
                            
                    dot = (x1, y1, z1, x2, y2, z2) -> x1 * x2 + y1 * y2 + z1 * z2
                    
                    distanceTo = (plane, vertex, obj) -> dot obj.location[0] - vertices[vertex][0][obj.triangle], obj.location[1] - vertices[vertex][1][obj.triangle], obj.location[2] - vertices[vertex][2][obj.triangle], plane[0][obj.triangle], plane[1][obj.triangle], plane[2][obj.triangle]
                                           
                    callback
                    
Call the "constrain" property with an object containing:

- location: An array of three numbers specifying the X, Y and Z moved to.
- triangle: An integer specifying the triangle index which contained the entity
            last frame.
            
This will modify these properties to constrain the entity to the surface of the 
navmesh.
                    
                        constrain: (obj) ->
                            for iterations in [0...25]
                                distanceA = distanceTo edgeNormals[0], 0, obj
                                distanceB = distanceTo edgeNormals[1], 1, obj
                                distanceC = distanceTo edgeNormals[2], 2, obj
                                if distanceA >= 0 and distanceB >= 0 and distanceC >= 0 
                                    break
                                
                                neighborA = neighbors[0][obj.triangle]
                                neighborB = neighbors[1][obj.triangle]                                
                                neighborC = neighbors[2][obj.triangle]

                                if distanceA < 0 and neighborA isnt 65535
                                    obj.triangle = neighborA
                                    continue
                                    
                                if distanceB < 0 and neighborB isnt 65535
                                    obj.triangle = neighborB
                                    continue
                                    
                                if distanceC < 0 and neighborC isnt 65535
                                    obj.triangle = neighborC
                                    continue
                                
                                if distanceA < 0 and distanceB < 0
                                    for axis in [0...3]
                                        obj.location[axis] = vertices[1][axis][obj.triangle]
                                    continue
                                    
                                if distanceB < 0 and distanceC < 0
                                    for axis in [0...3]
                                        obj.location[axis] = vertices[2][axis][obj.triangle]
                                    continue
                                    
                                if distanceC < 0 and distanceA < 0
                                    for axis in [0...3]
                                        obj.location[axis] = vertices[0][axis][obj.triangle]
                                    continue

                                if distanceA < 0
                                    for axis in [0...3]
                                        obj.location[axis] -= edgeNormals[0][axis][obj.triangle] * distanceA
                                    continue
                                    
                                if distanceB < 0
                                    for axis in [0...3]
                                        obj.location[axis] -= edgeNormals[1][axis][obj.triangle] * distanceB
                                    continue
                                        
                                if distanceC < 0
                                    for axis in [0...3]
                                        obj.location[axis] -= edgeNormals[2][axis][obj.triangle] * distanceC
                                    continue
                                    
                            distance = distanceTo normals, 0, obj
                            for axis in [0...3]
                                obj.location[axis] -= normals[axis][obj.triangle] * distance
                            return
                            
                else
                    handleError "Failed to load navmesh file " + path
            return
        request.send null
        return