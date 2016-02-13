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

### Exporting point clouds from Blender

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

## Exporting navmeshes from Blender

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