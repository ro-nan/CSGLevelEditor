@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("CommandManager", "res://addons/csg_builder/managers/command_manager.tscn")
	add_autoload_singleton("SettingsManager", "res://addons/csg_builder/managers/settings_manager.tscn")


func _disable_plugin() -> void:
	remove_autoload_singleton("CommandManager")
	remove_autoload_singleton("SettingsManager")

var dock
func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	# Load the dock scene and instantiate it.
	var dock_scene = preload("res://addons/csg_builder/managers/settings_dock.tscn").instantiate()

	# Create the dock and add the loaded scene to it.
	dock = EditorDock.new()
	dock.add_child(dock_scene)

	dock.title = "Better CSG"

	# Note that LEFT_UL means the left of the editor, upper-left dock.
	dock.default_slot = DOCK_SLOT_LEFT_UL

	# Allow the dock to be on the left or right of the editor, and to be made floating.
	dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_FLOATING

	add_dock(dock)

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_dock(dock)
	# Erase the control from the memory.
	dock.queue_free()

func _handles_input() -> bool:
	return true
