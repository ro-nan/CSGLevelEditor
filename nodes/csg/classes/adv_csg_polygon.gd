@tool
class_name AdvancedCSGPolygon extends CSGPolygon3D

var handles : Array = []

func _ready() -> void:
	if not Engine.is_editor_hint(): return
	create_handles_square()

func create_handles_square():
	if get_child_count() == 0:
		add_handle(Vector3())
		var positions = [
			Vector3(0, 0, 0), # lower left
			Vector3(2, 0, 0), # lower right
			Vector3(2, 2, 0), # upper right
			Vector3(0, 2, 0)  # upper left
		]
		for pos in positions:
			var handle = add_handle(pos)
			handle.position = pos

	polygon.clear()
	handles = get_children(false).filter(func(x): return x is Handle)
	_update_handles()

var last_pos : Array = []
var was_moving := false
func _process(_delta: float) -> void:
	if not Engine.is_editor_hint(): return
	var updated_handles : Array = []
	for child in get_children():
		child = child as Handle
		if child is Handle and "Handle" in child.name:
			updated_handles.append(child)
	
	if updated_handles.map(func(x): return x.global_position) != last_pos:
		was_moving = true
	elif was_moving and MOUSE_BUTTON_LEFT in CommandManager.current_frame_mouse_event_indicies:
		handles = updated_handles
		_update_handles()
		was_moving = false
	
	last_pos = updated_handles.map(func(x): return x.global_position)

func _update_handles():
	pass

func add_handle(pos: Vector3) -> Handle:
	var handle = Handle.new()
	add_child(handle)
	handle.owner = get_tree().edited_scene_root
	handle.name = "Handle"
	handle.position = pos
	handles.append(handle)
	return handle
	
