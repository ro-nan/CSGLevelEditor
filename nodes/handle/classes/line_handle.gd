@tool
class_name LineHandle extends Handle

@export var start : Node3D
@export var end : Node3D

var SHAREDLOGIC : Handle = Handle.new()

var path : Path3D
func _ready() -> void:
	path = Path3D.new()
	add_child(path)
	path.top_level = true
	path.global_position = Vector3.ZERO
	path.owner = get_tree().edited_scene_root

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_instance_valid(start) or not is_instance_valid(end): return
	path.curve = Curve3D.new()
	path.curve.add_point(start.global_position)
	path.curve.add_point(end.global_position)
