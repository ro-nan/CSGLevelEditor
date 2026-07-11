@tool
class_name PathHandle extends Handle

var path : Path3D
func _ready() -> void:
	path = Path3D.new()
	add_child(path)
	path.top_level = true
	path.global_position = Vector3.ZERO
	path.owner = get_tree().edited_scene_root

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	path.curve = Curve3D.new()
	for i in get_children().filter(func(x): return x is Handle):
		path.curve.add_point(i.global_position)
