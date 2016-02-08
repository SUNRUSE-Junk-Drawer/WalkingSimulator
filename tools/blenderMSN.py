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
    floatPlanes = [
        [], [], [], # Vertices
        [], [], [],
        [], [], [],
        
        [], [], [], # Surface normal
        
        [], [], [], # A->B edge normal
        [], [], [], # B->C edge normal
        [], [], []  # C->A edge normal
    ]
    
    shortPlanes = [
        [], # A->B edge neighbour
        [], # B->C edge neighbour
        []  # C->A edge neighbour
    ]
    
    for polyId, poly in enumerate(mesh.polygons):
        if len(poly.loop_indices) > 3:
            raise RuntimeError("Please triangulate your navmesh")
        
        locations = []
        colors = []
        colIndex = 0
        for indx in poly.loop_indices:
            location = mesh.vertices[mesh.loops[indx].vertex_index].co
            locations.append((location[0], location[2], location[1]))
            colors.append(colLayer.data[colIndex].color)
            colIndex += 1
            
        edgeDifferences = []
        for vertex in range(0, 3):
            next = (vertex + 1) % 3
            edgeDifferences.append((
                locations[next][0] - locations[vertex][0],
                locations[next][1] - locations[vertex][1],
                locations[next][2] - locations[vertex][2]
            ))
            
        edgeLengths = []
        for edge in edgeDifferences:
            edgeLengths.append(math.sqrt(edge[0] * edge[0] + edge[1] * edge[1] + edge[2] * edge[2]))
        
        edgeNormals = []
        for index, edge in enumerate(edgeDifferences):
            length = edgeLengths[index]
            edgeNormals.append((edge[0] / length, edge[1] / length, edge[2] / length))
        
        for index, vertex in enumerate(locations):
            for axisId, axis in enumerate(vertex):
                floatPlanes[index * 3 + axisId].append(axis)
                
        floatPlanes[9].append(poly.normal[0])
        floatPlanes[10].append(poly.normal[2])
        floatPlanes[11].append(poly.normal[1])
        
        for vertex in range(0, 3):
            prev = mesh.vertices[mesh.loops[poly.loop_indices[vertex]].vertex_index].co
            next = mesh.vertices[mesh.loops[poly.loop_indices[(vertex + 1) % 3]].vertex_index].co
            
            found = False
            sharedNormal = (poly.normal[0], poly.normal[2], poly.normal[1])
            
            for triangleId, other in enumerate(mesh.polygons):
                if poly == other:
                    continue
                   
                foundPrev = False
                foundNext = False
                    
                for indx in other.loop_indices:
                    v = mesh.vertices[mesh.loops[indx].vertex_index].co
                    if v == prev:
                        foundPrev = True
                    elif v == next:
                        foundNext = True
                    
                if foundPrev and foundNext:
                
                    # We don't normalize this, but don't actually need to.
                    sharedNormal = (
                        poly.normal[0] + other.normal[0], 
                        poly.normal[2] + other.normal[2], 
                        poly.normal[1] + other.normal[1]
                    )
                    
                    shortPlanes[vertex].append(triangleId)
                    found = True
                    break
            
            if not found:
                shortPlanes[vertex].append(65535)
        
            edgeNormal = edgeNormals[vertex]
            floatPlanes[12 + vertex * 3].append(edgeNormal[1] * sharedNormal[2] - sharedNormal[1] * edgeNormal[2])
            floatPlanes[12 + vertex * 3 + 1].append(edgeNormal[2] * sharedNormal[0] - sharedNormal[2] * edgeNormal[0])
            floatPlanes[12 + vertex * 3 + 2].append(edgeNormal[0] * sharedNormal[1] - sharedNormal[0] * edgeNormal[1])
        
    file = open(self.properties.filepath, "wb")
    for plane in floatPlanes:
        for value in plane:
            file.write(struct.pack("f", value))
            
    for plane in shortPlanes:
        for value in plane:
            file.write(struct.pack("H", value))
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