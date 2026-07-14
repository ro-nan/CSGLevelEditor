@tool
class_name CSGWall extends AdvancedCSGMesh

@export var subdivisions := 0

func _ready() -> void:
	create_handles_square()

func _update_handles():
	var bm = BoxMesh.new()
	bm.subdivide_depth = subdivisions
	bm.subdivide_height = subdivisions
	bm.subdivide_width = subdivisions
	
	bm.size.x = (get_face_handle(6, 2, 8, 4).x - get_face_handle(3, 7, 1, 5).x) / 2.0
	bm.size.y = (get_face_handle(3, 7, 4, 8).y - get_face_handle(1, 5, 6, 2).y) / 2.0
	bm.size.z = (get_face_handle(7, 8, 5, 6).z - get_face_handle(3, 4, 1, 2).z) / 2.0
	
	for i in handles:
		i.global_basis = Basis(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1))

	var face_center = Vector3.ZERO
	for handle in handles.slice(0, 8):
		face_center += handle.position
	face_center /= 8.0

	var faces = bm.get_faces()
	for i in range(faces.size()):
		faces[i] += face_center

	var mesh_helper := MeshTool.new()
	mesh = mesh_helper.create_array_mesh_from_faces(faces)
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	var half_x = bm.size.x / 2.0
	var half_y = bm.size.y / 2.0
	var half_z = bm.size.z / 2.0
	
	var left_face = get_face_handle(3, 7, 1, 5)
	var right_face = get_face_handle(6, 2, 8, 4)
	var bottom_face = get_face_handle(1, 5, 6, 2)
	var top_face = get_face_handle(3, 7, 4, 8)
	var back_face = get_face_handle(3, 4, 1, 2)
	var front_face = get_face_handle(7, 8, 5, 6)

	for j in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex(j)
		
		var nx = remap(v.x, face_center.x - half_x, face_center.x + half_x, 0.0, 1.0) if half_x > 0 else 0.5
		var ny = remap(v.y, face_center.y - half_y, face_center.y + half_y, 0.0, 1.0) if half_y > 0 else 0.5
		var nz = remap(v.z, face_center.z - half_z, face_center.z + half_z, 0.0, 1.0) if half_z > 0 else 0.5
		
		var x_pos = lerp(left_face, right_face, nx)
		var y_pos = lerp(bottom_face, top_face, ny)
		var z_pos = lerp(back_face, front_face, nz)
		
		var final_pos = x_pos + (y_pos - face_center) + (z_pos - face_center)
		mdt.set_vertex(j, final_pos)
	
	for i in handles:
		if not i is SculptHandle:
			continue
			
		var r = range(mdt.get_vertex_count()).map(func(x): return mdt.get_vertex(x))
		var _r = r.duplicate()
		_r.sort_custom(func(a, b): return a.distance_to(i.position) < b.distance_to(i.position))
		
		if _r.is_empty():
			continue
			
		var target_point = _r[0]
		
		for j in range(mdt.get_vertex_count()):
			var v = mdt.get_vertex(j)
			var d = v.distance_to(target_point)
			
			if is_instance_valid(i) and d < (i as Handle).max_effect_range:
				var weight = (i as Handle).get_point_effect(d)
				mdt.set_vertex(j, 
					Vector3(v.x, v.y, v.z) * (1.0 - weight) + i.position * weight
				)
	
	var sides = 6
	var face_groups := []
	for i in range(sides):
		face_groups.append(PackedVector3Array())

	for f in range(mdt.get_face_count()):
		var a = mdt.get_vertex(mdt.get_face_vertex(f, 0))
		var b = mdt.get_vertex(mdt.get_face_vertex(f, 1))
		var c = mdt.get_vertex(mdt.get_face_vertex(f, 2))
		var normal = (b - a).cross(c - a).normalized()
		var absn = Vector3(abs(normal.x), abs(normal.y), abs(normal.z))
		var side_index = 0
		if absn.x >= absn.y and absn.x >= absn.z:
			side_index = 0 if normal.x >= 0 else 1
		elif absn.y >= absn.x and absn.y >= absn.z:
			side_index = 2 if normal.y >= 0 else 3
		else:
			side_index = 4 if normal.z >= 0 else 5
		face_groups[side_index].append_array([a, b, c])

	var new_mesh := ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	for face_vertices in face_groups:
		if face_vertices.is_empty():
			continue
		arrays[Mesh.ARRAY_VERTEX] = face_vertices
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	mesh = new_mesh

func _add_handle() -> Handle:
	var handle = Handle.new()
	add_child(handle)
	handle.owner = get_tree().edited_scene_root
	handle.name = "Handle"
	handle.global_position = global_position if len(handles) < 2 else (handles[len(handles)-2].global_position + handles[len(handles)-1].global_position) / 2.0
	handles.append(handle)
	return handle

func get_face_handle(p1 : int, p2 : int, p3 : int, p4 : int) -> Vector3:
	return ((handles[p1-1].position + handles[p2-1].position) / 2.0 + (handles[p3-1].position + handles[p4-1].position) / 2.0) / 2.0
