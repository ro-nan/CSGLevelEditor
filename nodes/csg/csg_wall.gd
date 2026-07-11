@tool
class_name CSGWall extends AdvancedCSGMesh

@export var subdivisions := 0

func _ready() -> void:
	create_handles_square()

func _update_handles():
	var faces = BoxMesh.new().get_faces()
	
	var mesh_helper := MeshTool.new()
	
	mesh = mesh_helper.create_array_mesh_from_faces(faces)
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in handles:
		var r = range(mdt.get_vertex_count()).map(func(x): return mdt.get_vertex(x))
		var _r = r.duplicate()
		_r.sort_custom(func(a, b): return a.distance_to(i.position) < b.distance_to(i.position))
		
		var target_point = _r[0]
		# For every point within the target influence, move it to the handle's position
		for j in range(mdt.get_vertex_count()):
			var v = mdt.get_vertex(j)
			var d = v.distance_to(target_point)
			if not i is SculptHandle:
				if d < 0.1 and i in handles.slice(0, 8):
					mdt.set_vertex(j, i.position)
			elif is_instance_valid(i) and d < (i as Handle).max_effect_range:
				if i is SculptHandle:
					mdt.set_vertex(j,
						Vector3(v.x, v.y, v.z) * (1 - (i as Handle).get_point_effect(d)) +
						i.position * (i as Handle).get_point_effect(d)
					)
	
	var updated_faces := PackedVector3Array()
	updated_faces.resize(mdt.get_vertex_count())
	for j in range(mdt.get_vertex_count()):
		updated_faces[j] = mdt.get_vertex(j)

	var new_mesh := ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	for face_idx in range(6):
		var face_vertices := PackedVector3Array()
		face_vertices.resize(6)
		for k in range(6):
			face_vertices[k] = updated_faces[face_idx * 6 + k]
		if subdivisions > 0:
			face_vertices = _subdivide_face(face_vertices, subdivisions)
		arrays[Mesh.ARRAY_VERTEX] = face_vertices
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	mesh = new_mesh

func _subdivide_face(face_vertices: PackedVector3Array, level: int) -> PackedVector3Array:
	var subdivided := PackedVector3Array()
	for t in range(2):
		var a = face_vertices[t * 3 + 0]
		var b = face_vertices[t * 3 + 1]
		var c = face_vertices[t * 3 + 2]
		subdivided.append_array(_subdivide_triangle(a, b, c, level))
	return subdivided

func _subdivide_triangle(a: Vector3, b: Vector3, c: Vector3, level: int) -> PackedVector3Array:
	if level <= 0:
		var triangle = PackedVector3Array()
		triangle.append_array([a, b, c])
		return triangle

	var ab = (a + b) * 0.5
	var bc = (b + c) * 0.5
	var ca = (c + a) * 0.5

	var subdivided := PackedVector3Array()
	subdivided.append_array(_subdivide_triangle(a, ab, ca, level - 1))
	subdivided.append_array(_subdivide_triangle(ab, b, bc, level - 1))
	subdivided.append_array(_subdivide_triangle(ca, bc, c, level - 1))
	subdivided.append_array(_subdivide_triangle(ab, bc, ca, level - 1))
	return subdivided

func _add_handle() -> Handle:
	var handle = Handle.new()
	add_child(handle)
	handle.owner = get_tree().edited_scene_root
	handle.name = "Handle"
	handle.global_position = global_position if len(handles) < 2 else (handles[len(handles)-2].global_position + handles[len(handles)-1].global_position) / 2.0
	handles.append(self)
	return handle
