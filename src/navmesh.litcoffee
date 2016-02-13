# navmesh

Navmeshes are stored as "MSN" (MasSplat Navmesh) and are used to define where 
entities (including the player) can travel.  By default, they are unable to 
leave the surface, "crawling" over it.  Each tile is a 3D triangle.  A light 
Any two triangles sharing two vertices are joined and the edge formed may be 
crossed from one to the other, otherwise, the edge is treated as a form of wall.

MSN is a binary format.  It is comprised of:

| Type    | Num.              | Description                                                |
| ------- | ----------------- | ---------------------------------------------------------- |
| uint16  | 1                 | The number of vertices defined.                            |
| uint16  | 1                 | The number of triangles defined.                           |
| float32 | 3x num. vertices  | The X, Y and Z of each vertex.                             |
| uint16  | 3x num. triangles | The first, second and third vertex index of each triangle. |

On calling with the path to a MSN file and a callback, reads the MSN file and
executes the callback with an object as the argument.
    
    file = require "./file.litcoffee"
    vector = require "./vector.litcoffee"
    plane = require "./plane.litcoffee"
    
    module.exports = (path, callback) ->
        file.arrayBuffer path, (response) ->
            header = new Uint16Array response, 0, 2
            vertexData = new Float32Array response, 4, header[0] * 3
            indices = new Uint16Array response, 4 + header[0] * 4 * 3, header[1] * 3
        
            vertices = for i in [0...vertexData.length] by 3
                [
                    vertexData[i]
                    vertexData[i + 1]
                    vertexData[i + 2]
                ]
        
            triangles = for i in [0...indices.length] by 3
                plane: plane.fromTriangle vertices[indices[i]], vertices[indices[i + 1]], vertices[indices[i + 2]]
                indices: [
                    indices[i]
                    indices[i + 1]
                    indices[i + 2]
                ]
        
            for triangle in triangles
                triangle.edges = for edge in [0...3]
                    vertexA = triangle.indices[edge]
                    vertexB = triangle.indices[(edge + 1) % 3]
                    vertexC = []
                    vector.add.vector vertices[vertexA], triangle.plane.normal, vertexC
                    neighbor = null
                    for other in triangles
                        if triangle is other then continue
                        if vertexA not in other.indices then continue
                        if vertexB not in other.indices then continue
                        neighbor = other
                        vector.add.vector vertexC, other.plane.normal, vertexC
                        break
                    neighbor: neighbor
                    plane: plane.fromTriangle vertices[vertexA], vertexC, vertices[vertexB]
                   
            callback
            
Call the "constrain" property with an object containing:

- location: An array of three numbers specifying the X, Y and Z moved to.
- triangle: A reference to the triangle the entity is currently in.  If not
    known, falsy.
    
This will modify these properties to constrain the entity to the surface of the 
navmesh.
            
                constrain: (obj) ->
                    if not obj.triangle
                        obj.triangle = triangles[0]
                    
                    for iterations in [0...25]
                        distanceA = plane.distance obj.triangle.edges[0].plane, obj.location
                        distanceB = plane.distance obj.triangle.edges[1].plane, obj.location
                        distanceC = plane.distance obj.triangle.edges[2].plane, obj.location
                        if distanceA >= 0 and distanceB >= 0 and distanceC >= 0 
                            break

                        if distanceA < 0 and obj.triangle.edges[0].neighbor
                            obj.triangle = obj.triangle.edges[0].neighbor
                            continue
                            
                        if distanceB < 0 and obj.triangle.edges[1].neighbor
                            obj.triangle = obj.triangle.edges[1].neighbor
                            continue
                            
                        if distanceC < 0 and obj.triangle.edges[2].neighbor
                            obj.triangle = obj.triangle.edges[2].neighbor
                            continue
                        
                        if distanceA < 0 and distanceB < 0
                            vector.copy vertices[obj.triangle.indices[1]], obj.location
                            continue
                            
                        if distanceB < 0 and distanceC < 0
                            vector.copy vertices[obj.triangle.indices[2]], obj.location
                            continue
                            
                        if distanceC < 0 and distanceA < 0
                            vector.copy vertices[obj.triangle.indices[0]], obj.location
                            continue

                        if distanceA < 0
                            plane.project obj.triangle.edges[0].plane, obj.location, obj.location
                            continue
                            
                        if distanceB < 0
                            plane.project obj.triangle.edges[1].plane, obj.location, obj.location
                            continue
                                
                        if distanceC < 0
                            plane.project obj.triangle.edges[2].plane, obj.location, obj.location
                            continue
                            
                    plane.project obj.triangle.plane, obj.location, obj.location
                    return        
            return
        return