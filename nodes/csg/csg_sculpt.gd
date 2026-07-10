@tool
class_name CSGSculpt extends AdvancedCSGMesh

@export var initial_mesh : Mesh

func _ready() -> void:
	create_handles_square()

func _update_handles():
	var faces = initial_mesh.get_faces()
	
	var mesh_helper := MeshTool.new()
	
	mesh = mesh_helper.create_array_mesh_from_faces(faces)
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in handles:
		var r = range(mdt.get_vertex_count()).map(func(x): return mdt.get_vertex(x))
		var _r = r.duplicate()
		_r.sort_custom(func(a, b): return a.distance_to(i.position) < b.distance_to(i.position))
		
		var target_index = r.find(_r[0])
		var target_point = _r[0]
		# For every point within 0.05 m of target point, move it to the handle's position
		for j in range(mdt.get_vertex_count()):
			var v = mdt.get_vertex(j)
			var d = v.distance_to(target_point)
			if d < (i as Handle).max_effect_range:
				if i is SculptHandle:
					mdt.set_vertex(j, 
						Vector3(v.x, v.y, v.z) * (1 - (i as Handle).get_point_effect(d)) +
						(i.position) * (i as Handle).get_point_effect(d)
					)
	
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	
