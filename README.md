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

A navmesh is used to define where entities (including the player) can travel.
By default, they are unable to leave the surface, "crawling" over it.  Each tile
is a 3D triangle.  A light colour is set at each vertex.  Any two triangles 
sharing two vertices are joined and the edge formed may be crossed from one to 
the other.

The file format is JSON-based and looks like:

    {
        "triangles": [{
            "vertices": [{
                "location": [4, 7, 2],
                "color": [0.6, 0.2, 0.1]
            }, {
                "location": [7, 2, 9],
                "color": [0.6, 0.2, 0.1]
            }, 
            {
                "location": [10, 14, 12],
                "color": [0.6, 0.2, 0.1]
            }],
            "normal": [0.7, -0.7, 0.0]
            "edges": [{
                "normal": [1.0, 0.0, 0.0],
                "triangle": null
            }, {
                "normal": [0.0, -0.7, -0.7],
                "triangle": 20
            }, {
                "normal": [0.1, 0.6, 0.2],
                "triangle": 6
            }]
        }, ...]
    }
    
Vertices' locations are in X, Y and Z, while their colours are in normalized
(0...1) RGB.

The "edges" array contains 3 objects describing the edges between vertices 0->1, 
1->2 and 2->0 in order.  If "triangle" is null, the edge does not border another
triangle.  If it is non-null, it is an index into the "triangles" array.