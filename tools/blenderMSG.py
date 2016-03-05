bl_info = {
  "name": "MSG",
  "author": "jameswilddev",
  "version": (0, 0, 0),
  "blender": (2, 7, 0),
  "location": "File > Export > MasSplat Geometry (.msg)",
  "description": "Export triangles as MasSplat Geometry (.msg)",
  "category": "Import-Export"
}

import bpy, struct, math, random

class ExportMSG(bpy.types.Operator):
  bl_idname = "export.msg"
  bl_label = "Export MSG"
  
  filepath = bpy.props.StringProperty(name="File Path", description="The path to a file to export to.", maxlen=1024, default="")
  
  def execute(self, context):
    vertices = []
    indices = []
    
    for obj in bpy.context.selected_objects:
        if obj.type != "MESH":
            continue
            
        mesh = obj.to_mesh(bpy.context.scene, True, "PREVIEW")
        mesh.transform(obj.matrix_world)
        colLayer = mesh.vertex_colors[0]
    
        i = 0
        for poly in mesh.polygons:
            if len(poly.loop_indices) != 3:
                raise RuntimeError("Please triangulate your meshes")
            for index in poly.loop_indices:
                vertex = mesh.vertices[mesh.loops[index].vertex_index].co
                color = colLayer.data[i].color
                
                built = ((vertex[0], vertex[2], vertex[1]), (color[0], color[1], color[2]))
                
                if not built in vertices:
                    vertices.append(built)
                indices.append(vertices.index(built))
                i = i + 1
            
    file = open(self.properties.filepath, "wb")
    
    file.write(struct.pack("H", len(vertices)))
    file.write(struct.pack("H", len(indices) // 3))
    
    for vertex in vertices:
        for axis in vertex[0]:
            file.write(struct.pack("f", axis))

    for vertex in vertices:
        for channel in vertex[1]:
            file.write(struct.pack("B", int(channel * 255)))
            
    for index in indices:
        file.write(struct.pack("H", index))
        
    file.close()
    return {"FINISHED"}

  def invoke(self, context, event):
    wm = context.window_manager
    self.properties.filepath = ""
    wm.fileselect_add(self)
    return {"RUNNING_MODAL"}

def menu_func(self, context):
  self.layout.operator(ExportMSG.bl_idname, text="MasSplat Geometry (.msg)")
  
def register():
  bpy.utils.register_class(ExportMSG)
  bpy.types.INFO_MT_file_export.append(menu_func)

def unregister():
  bpy.utils.unregister_class(ExportMSG)
  bpy.types.INFO_MT_file_export.remove(menu_func)

if __name__ == "__main__":
  register()