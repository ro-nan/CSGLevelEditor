@tool
class_name PathHandle extends Handle

var path : Path3D
func _ready() -> void:
	if not Engine.is_editor_hint(): return
	for i in get_children():
		if i is Path3D:
			return
	
	path = Path3D.new()
	add_child(path)
	path.top_level = true
	path.global_position = Vector3.ZERO
	path.owner = get_tree().edited_scene_root

func _process(delta: float) -> void:
	if path == null:
		path = get_children().filter(func(x): return x is Path3D)[0]
	path.curve = Curve3D.new()
	for i in get_children().filter(func(x): return x is Handle):
		path.curve.add_point(i.global_position)
