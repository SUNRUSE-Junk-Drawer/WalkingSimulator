bl_info = {
  "name": "MSN",
  "author": "jameswilddev",
  "version": (0, 0, 0),
  "blender": (2, 7, 0),
  "location": "File > Export > MasSplat Navmesh (.msn)",
  "description": "Export triangles as a MasSplat Navmesh (.msn)",
  "category": "Import-Export"
}

import bpy, struct, math, random

class ExportMSN(bpy.types.Operator):
  bl_idname = "export.msn"
  bl_label = "Export MSN"
  
  filepath = bpy.props.StringProperty(name="File Path", description="The path to a file to export to.", maxlen=1024, default="")
  
  def execute(self, context):
    obj = bpy.data.objects["navmesh"]
    mesh = obj.to_mesh(bpy.context.scene, True, "PREVIEW")
    mesh.transform(obj.matrix_world)
    colLayer = mesh.vertex_colors[0]

    vertices = []
    indices = []
    
    for poly in mesh.polygons:
        if len(poly.loop_indices) != 3:
            raise RuntimeError("Please triangulate your navmesh")
        for index in poly.loop_indices:
            vertex = mesh.vertices[mesh.loops[index].vertex_index].co
            if not vertex in vertices:
                vertices.append(vertex)
            indices.append(vertices.index(vertex))
            
    file = open(self.properties.filepath, "wb")
    
    file.write(struct.pack("H", len(vertices)))
    file.write(struct.pack("H", len(indices) // 3))
    
    for vertex in vertices:
        file.write(struct.pack("f", vertex[0]))
        file.write(struct.pack("f", vertex[2]))
        file.write(struct.pack("f", vertex[1]))
            
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
  self.layout.operator(ExportMSN.bl_idname, text="MasSplat Navmesh (.msn)")
  
def register():
  bpy.utils.register_class(ExportMSN)
  bpy.types.INFO_MT_file_export.append(menu_func)

def unregister():
  bpy.utils.unregister_class(ExportMSN)
  bpy.types.INFO_MT_file_export.remove(menu_func)

if __name__ == "__main__":
  register()