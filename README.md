# MasSplat

A demo for an experimental renderer written in WebGL which draws scenes as point
clouds of "splats", which are billboards textured to look like paint strokes.

## Setup

- Download or clone the repository.
- Navigate to the directory where "package.json" is in a terminal with NPM
  installed.
- Run "npm install".
- All dependencies should install and the "dist" directory be created containing
  all content required.
- At present, you will then have to host these files statically on a web server.
  Running from the filesystem will not work, as currently AJAX is used to
  retrieve point cloud files.
  
If you would like to have your install automatically rebuild when the "src"
directory changes, run "npm run-script watch" after "npm install".

## Point Clouds

Point clouds are stored as "MSC" (MasSplat Cloud) files, which are binary vertex 
buffers loaded directly into WebGL.  Each splat is described four times, once 
for each vertex of the quadrilateral, clockwise from the bottom left.

3D space is defined as:

- x: left to right
- y: bottom to top
- z: back to front

| Type    | Num. | Description                                                            |
| ------- | ---- | ---------------------------------------------------------------------- |
| float32 | 3    | The location of the origin in world space.  (XYZ)                      |
| ubyte   | 3    | The intensities of the red, green and blue channels.                   |
| ubyte   | 1    | In animated clouds, a bone ID.  Otherwise, padding.                    |
| float32 | 2    | The location of the vertex relative to the origin in view space.  (XY) |

### Exporting from Blender

A Python export script is included for generating "MSC" files.  To install it:

- File -> User Preferences -> Add Ons
- At the bottom, click "Install from File..."
- Select the "blenderMSC.py" file in the "tools" directory of this repository.
- Type "MSC" into the search box in the top left corner of the window.
- Check the tickbox which appears in the top right corner of the 
  "Import-Export: MSC" row.

This script will export all selected objects' faces as splats.  To use it, go to
File -> Export -> MasSplat Cloud (.msc)  

The colour and origin of the splat are the averages of the face, while the 
radius is calculated to reach the furthest vertex from the origin.  The splats 
can be scaled up or down using the "Splat Size Multiplier" on the left side when
choosing where to export to.  Any modifiers or transforms will be applied before
export.  Y and Z will be automatically swapped.

Animated point clouds are currently not exportable.

## Navmeshes

Navmeshes are stored as "MSN" (MasSplat Navmesh) and are used to define where 
entities (including the player) can travel.  By default, they are unable to 
leave the surface, "crawling" over it.  Each tile is a 3D triangle.  A light 
Any two triangles sharing two vertices are joined and the edge formed may be 
crossed from one to the other, otherwise, the edge is treated as a form of wall.

MSN is a binary format formed of "planes"; the X axis of the location of vertex
A of every triangle, then the Y axis of the location of vertex B of every
triangle and so on.  The following planes are currently defined:

| Type    | Description                                                                                                          |
| ------- | -------------------------------------------------------------------------------------------------------------------- |
| float32 | The location on the X axis of the first vertex.                                                                      |
| float32 | The location on the Y axis of the first vertex.                                                                      |
| float32 | The location on the Z axis of the first vertex.                                                                      |
| float32 | The location on the X axis of the second vertex.                                                                     |
| float32 | The location on the Y axis of the second vertex.                                                                     |
| float32 | The location on the Z axis of the second vertex.                                                                     |
| float32 | The location on the X axis of the third vertex.                                                                      |
| float32 | The location on the Y axis of the third vertex.                                                                      |
| float32 | The location on the Z axis of the third vertex.                                                                      |
| float32 | The X axis of the surface normal.                                                                                    |
| float32 | The Y axis of the surface normal.                                                                                    |
| float32 | The Z axis of the surface normal.                                                                                    |
| float32 | The X axis of a vector pointing inwards from the edge between the first and second vertices.                         |
| float32 | The Y axis of a vector pointing inwards from the edge between the first and second vertices.                         |
| float32 | The Z axis of a vector pointing inwards from the edge between the first and second vertices.                         |
| float32 | The X axis of a vector pointing inwards from the edge between the second and third vertices.                         |
| float32 | The Y axis of a vector pointing inwards from the edge between the second and third vertices.                         |
| float32 | The Z axis of a vector pointing inwards from the edge between the second and third vertices.                         |
| float32 | The X axis of a vector pointing inwards from the edge between the third and first vertices.                          |
| float32 | The Y axis of a vector pointing inwards from the edge between the third and first vertices.                          |
| float32 | The Z axis of a vector pointing inwards from the edge between the third and first vertices.                          |
| uint16  | The neighbouring triangle index over the edge between the first and second vertices.  (65535 indicates no neighbour) |
| uint16  | The neighbouring triangle index over the edge between the second and third vertices.  (65535 indicates no neighbour) |
| uint16  | The neighbouring triangle index over the edge between the third and first vertices.  (65535 indicates no neighbour)  |

3D space is defined as:

- x: left to right
- y: bottom to top
- z: back to front

Future versions will export vertex colour too for lighting entities on the
navmesh.

### Exporting from Blender

A Python export script is included for generating "MSN" files.  To install it:

- File -> User Preferences -> Add Ons
- At the bottom, click "Install from File..."
- Select the "blenderMSN.py" file in the "tools" directory of this repository.
- Type "MSN" into the search box in the top left corner of the window.
- Check the tickbox which appears in the top right corner of the 
  "Import-Export: MSN" row.

This script will export every triangle in the mesh as a navmesh tile.  To use
it, go to File -> Export -> MasSplat Navmesh (.msc)  

Only the object named "navmesh" will be exported.  Any modifiers or transforms 
will be applied before export.  Y and Z will be automatically swapped.