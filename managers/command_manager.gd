@tool
extends Node

const EXTNAME := "AdvCSG"
const HANDLE_SPHERE_DISTANCE := 0.5
const HANDLE_SPHERE_RADIUS := 5.0

var commands : Array[Command]

class Command:
	var toaster : EditorToaster :
		get():
			return EditorInterface.get_editor_toaster()
	
	var c_name := "UNNAMEDCOMMAND" # Name of command
	var c_type := "" # Category of command
	
	var _do : Callable
	var _undo : Callable
	
	var input_combo : Array[Key]
	
	var undo_redo_manager : EditorUndoRedoManager
	
	var data : Dictionary[String, Variant]
	
	func _init(name : String, type : String, _do : Callable, _undo : Callable, input_combo : Array[Key]):
		self.c_name = name
		self.c_type = type
		
		self._do = _do
		self._undo = _undo
		
		self.input_combo = input_combo
		
		var command_palette : EditorCommandPalette = EditorInterface.get_command_palette()
		command_palette.add_command(c_name, EXTNAME + "/" + (c_type + "/" + c_name if c_type != "" else c_name), Callable(self.do), h_stringify(input_combo))
	
	func do():
		undo_redo_manager = EditorInterface.get_editor_undo_redo()
		undo_redo_manager.create_action(c_name)
		undo_redo_manager.add_do_method(self, "do_internal")
		undo_redo_manager.add_undo_method(self, "undo")
		undo_redo_manager.commit_action(true)
	
	func do_internal():
		_do.call(self)
	
	func undo():
		_undo.call(self)
	
	# Helpers
	func h_stringify(a : Array) -> String:
		var o := ""
		for i in a:
			o += str(i)
		
		return o

func _ready() -> void:
	if not Engine.is_editor_hint(): return
	print("Registering Commands...")
	
	commands.append(Command.new("Add Handle", "", add_handle_do, add_handle_undo, [KEY_X]))
	commands.append(Command.new("Add Sphere Handles", "Handles", add_sphere_handles_do, add_sphere_handles_undo, [KEY_H]))
	
	print("DONE")

func add_handle_do(command : Command):
	var selection := EditorInterface.get_selection()
	var nodes: Array[Node] = selection.get_selected_nodes()
	for n in nodes:
		if not n is AdvancedCSGMesh:	continue
		n = n as AdvancedCSGMesh
		
		if command.data.has("nodes"):
			command.data["nodes"].append(n.add_handle(Vector3()))
		else:
			command.data["nodes"] = [n.add_handle(Vector3())]

func add_handle_undo(command : Command):
	print(command.data)
	if command.data.has("nodes"):
		(command.data["nodes"].back() as Node).queue_free.call_deferred()
	
		command.data["nodes"].pop_back()

func add_sphere_handles_do(command : Command):
	return
	var selection := EditorInterface.get_selection()
	var nodes: Array[Node] = selection.get_selected_nodes()
	var created_handles := []
	for n in nodes:
		if not n is Node3D:
			continue
		var node3d := n as Node3D
		for point in _build_sphere_handle_points():
			var handle := Handle.new()
			handle.name = "Handle"
			handle.conform_to_grid = false
			node3d.add_child(handle)
			handle.owner = get_tree().edited_scene_root
			handle.position = point
			created_handles.append(handle)
	
	if created_handles.is_empty():
		return
	
	if command.data.has("nodes"):
		command.data["nodes"].append_array(created_handles)
	else:
		command.data["nodes"] = created_handles

func add_sphere_handles_undo(command : Command):
	if not command.data.has("nodes"):
		return
	
	for handle in command.data["nodes"].duplicate():
		if is_instance_valid(handle):
			handle.queue_free.call_deferred()
	command.data.erase("nodes")

func _build_sphere_handle_points() -> Array:
	var points := []
	var lat_steps := max(4, int(ceil(PI * HANDLE_SPHERE_RADIUS / (HANDLE_SPHERE_DISTANCE * 4.0))))
	var lon_steps := max(8, int(ceil(TAU * HANDLE_SPHERE_RADIUS / (HANDLE_SPHERE_DISTANCE * 4.0))))
	for lat_index in range(1, lat_steps):
		var lat := (float(lat_index) / float(lat_steps)) * PI - PI / 2.0
		var cos_lat := cos(lat)
		var sin_lat := sin(lat)
		for lon_index in range(lon_steps):
			var lon := (float(lon_index) / float(lon_steps)) * TAU
			points.append(Vector3(
				cos_lat * cos(lon),
				cos_lat * sin(lon),
				sin_lat
			) * HANDLE_SPHERE_RADIUS)
	return points

func _process(delta: float) -> void:
	if not Engine.is_editor_hint(): return
	for i in commands:
		var t_ln = 0
		if i.input_combo == current_frame_button_event_indicies:
			i.do()
	
	for i in current_frame_input_events:
		if not i.is_pressed():
			for a in current_frame_input_events.filter(func(x): return x.keycode == i.keycode):
				current_frame_input_events.pop_at(current_frame_input_events.find(a))
	
	current_frame_input_events_mouse.clear()

var current_frame_input_events : Array[InputEvent]
var current_frame_input_events_mouse : Array[InputEvent]
var current_frame_mouse_event_indicies : Array :
	get():
		return CommandManager.current_frame_input_events_mouse.filter(func(x): return x is InputEventMouseButton).map(func(x): return x.button_index)
var current_frame_button_event_indicies : Array :
	get():
		return CommandManager.current_frame_input_events.filter(func(x): return x is InputEventKey).map(func(x): return x.keycode)

func _input(event: InputEvent) -> void:
	if not Engine.is_editor_hint(): return
	if event is InputEventKey:
		current_frame_input_events.append(event)
	elif event is InputEventMouseButton:
		current_frame_input_events_mouse.append(event)
