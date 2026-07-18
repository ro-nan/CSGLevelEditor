@tool
class_name AdvancedMultimesh
extends MultiMeshInstance3D

var handles : Array = []

func _ready() -> void:
	create_handles_square()

func create_handles_square():
	if get_child_count() == 0:
		for i in range(8):
			var handle = _add_handle()
			handle.position = Vector3((i % 2) * 2 - 1, (i / 2) % 2 * 2 - 1, (i / 4) * 2 - 1)
	
	_update_handles()

var last_pos : Array = []
var was_moving := false
func _process(_delta: float) -> void:
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

# Controller Calls
func _add_handle() -> Handle:
	var handle = Handle.new()
	add_child(handle)
	handle.owner = get_tree().edited_scene_root
	handle.name = "Handle"
	handle.global_position = global_position if len(handles) < 2 else (handles[len(handles)-2].global_position + handles[len(handles)-1].global_position) / 2.0
	handles.append(self)
	return handle
	
