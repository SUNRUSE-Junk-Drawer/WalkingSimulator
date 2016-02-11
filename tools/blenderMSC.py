bl_info = {
  "name": "MSC",
  "author": "jameswilddev",
  "version": (0, 0, 0),
  "blender": (2, 7, 0),
  "location": "File > Export > MasSplat Cloud (.msc)",
  "description": "Export face centres as a MasSplat Cloud (.msc)",
  "category": "Import-Export"
}

import bpy, struct, math, random

class ExportMSC(bpy.types.Operator):
  bl_idname = "export.msc"
  bl_label = "Export MSC"
  
  filepath = bpy.props.StringProperty(name="File Path", description="The path to a file to export to.", maxlen=1024, default="")
  splatSizeMultiplier = bpy.props.FloatProperty(name="Splat Size Multiplier", description="By default, splats are the size of the face.  Increase this if you see gaps.", step=0.1, min=0.0, default=1.3)
  
  def execute(self, context):

    # This is complicated somewhat by the fact that vertices don't have colour.
    # Instead, the faces' references to the vertices have colour, so two faces
    # sharing a vertex can have different colours.
    # As such, the mean average of the colours applicable to a vertex are used.
    file = open(self.properties.filepath, "wb")
    for obj in bpy.context.selected_objects:
      if obj.type == "MESH":
        mesh = obj.to_mesh(bpy.context.scene, True, "PREVIEW")
        mesh.transform(obj.matrix_world)
        i = 0
        colLayer = mesh.vertex_colors[0]
        blending = {}
        for poly in mesh.polygons:
          x = 0
          y = 0
          z = 0
          red = 0
          green = 0
          blue = 0
          for indx in poly.loop_indices:
            location = mesh.vertices[mesh.loops[indx].vertex_index].co
            x += location[0]
            y += location[2]
            z += location[1]
            color = colLayer.data[i].color
            red += color[0]
            green += color[1]
            blue += color[2]
            i += 1
          x /= len(poly.loop_indices)
          y /= len(poly.loop_indices)
          z /= len(poly.loop_indices)
          red /= len(poly.loop_indices)
          green /= len(poly.loop_indices)
          blue /= len(poly.loop_indices)
          radius = 0
          for indx in poly.loop_indices:
            location = mesh.vertices[mesh.loops[indx].vertex_index].co
            xDiff = x - location[0]
            yDiff = y - location[2]
            zDiff = z - location[1]
            thisRadius = math.sqrt(xDiff * xDiff + yDiff * yDiff + zDiff * zDiff)
            if thisRadius > radius:
              radius = thisRadius
          radius *= self.properties.splatSizeMultiplier
          
          file.write(struct.pack("f", x))
          file.write(struct.pack("f", y))
          file.write(struct.pack("f", z))
          file.write(struct.pack("B", int(red * 255)))
          file.write(struct.pack("B", int(green * 255)))
          file.write(struct.pack("B", int(blue * 255)))
          file.write(struct.pack("B", 0)) # We need to pack this to 4-byte alignment.
          file.write(struct.pack("f", radius))
    file.close()
    return {"FINISHED"}

  def invoke(self, context, event):
    wm = context.window_manager
    self.properties.filepath = ""
    wm.fileselect_add(self)
    return {"RUNNING_MODAL"}

def menu_func(self, context):
  self.layout.operator(ExportMSC.bl_idname, text="MasSplat Cloud (.msc)")
  
def register():
  bpy.utils.register_class(ExportMSC)
  bpy.types.INFO_MT_file_export.append(menu_func)

def unregister():
  bpy.utils.unregister_class(ExportMSC)
  bpy.types.INFO_MT_file_export.remove(menu_func)

if __name__ == "__main__":
  register()