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

    file = require "./file.litcoffee"
    vector = require "./vector.litcoffee"
    plane = require "./plane.litcoffee"

## load

- filename: The "real" location of the MSN file to load.  (i.e. already 
            "require"-d)
- callback: A callback to execute with the array of objects representing the
            loaded objects on success, containing:
            
+ plane: A plane object for the surface of the triangle itself.
+ vertices: An array of vectors specifying the locations of the vertices which
            make up the triangle.
+ edges: An array of three objects representing the edges of the triangle,
       containing:
  
* neighbor: When null, there is no other triangle over this edge.  Otherwise
            a reference to the triangle object which can be found over it.
* plane: A plane facing inwards from the edge.  If this edge borders another
         triangle, this will be aligned to both this triangle and the 
         neighbor.
    
    load = (path, callback) ->
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
                vertices: [
                    vertices[indices[i]]
                    vertices[indices[i + 1]]
                    vertices[indices[i + 2]]
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

            callback triangles
            return
        return
            
## constrain

- A vector specifying the location moved to.
- A reference to the navmesh triangle which contained the location moved from.
- An optional callback executed when a wall is hit, with arguments:

+ The edge collided with.

Updates the location vector to take into account collision with navmesh triangle 
walls and returns the new containing navmesh triangle.
            
    constrain = (location, triangle, edgeCallback) ->
        
        for iterations in [0...25]
            distanceA = plane.distance triangle.edges[0].plane, location
            distanceB = plane.distance triangle.edges[1].plane, location
            distanceC = plane.distance triangle.edges[2].plane, location
            if distanceA >= 0 and distanceB >= 0 and distanceC >= 0 
                break

            if distanceA < 0 and triangle.edges[0].neighbor
                triangle = triangle.edges[0].neighbor
                continue
                
            if distanceB < 0 and triangle.edges[1].neighbor
                triangle = triangle.edges[1].neighbor
                continue
                
            if distanceC < 0 and triangle.edges[2].neighbor
                triangle = triangle.edges[2].neighbor
                continue
            
            if distanceA < 0 and distanceB < 0
                vector.copy triangle.vertices[1], location
                if edgeCallback
                    edgeCallback triangle.edges[0]
                    edgeCallback triangle.edges[1]
                continue
                
            if distanceB < 0 and distanceC < 0
                vector.copy triangle.vertices[2], location
                if edgeCallback
                    edgeCallback triangle.edges[1]
                    edgeCallback triangle.edges[2]
                continue
                
            if distanceC < 0 and distanceA < 0
                vector.copy triangle.vertices[0], location
                if edgeCallback
                    edgeCallback triangle.edges[2]
                    edgeCallback triangle.edges[0]
                continue

            if distanceA < 0
                plane.project triangle.edges[0].plane, location, location
                if edgeCallback then edgeCallback triangle.edges[0]
                continue
                
            if distanceB < 0
                plane.project triangle.edges[1].plane, location, location
                if edgeCallback then edgeCallback triangle.edges[1]
                continue
                    
            if distanceC < 0
                plane.project triangle.edges[2].plane, location, location
                if edgeCallback then edgeCallback triangle.edges[2]
                continue
                
        triangle
        
    module.exports = { load, constrain }