@tool
extends Node

const EXTNAME := "AdvCSG"

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
