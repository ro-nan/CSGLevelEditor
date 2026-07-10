@tool
extends EditorPlugin

# Replace this value with a PascalCase autoload name, as per the GDScript style guide.
const AUTOLOAD_NAME = "CommandManager"

func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/csg_builder/managers/command_manager.tscn")


func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

func _handles_input() -> bool:
	return true

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		CommandManager.pass_input_event(event)
