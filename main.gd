@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("CommandManager", "res://addons/csg_builder/managers/command_manager.tscn")
	add_autoload_singleton("SettingsManager", "res://addons/csg_builder/managers/settings_manager.tscn")


func _disable_plugin() -> void:
	remove_autoload_singleton("CommandManager")
	remove_autoload_singleton("SettingsManager")

var dock
var toggle_locked_btn: CheckButton
var update_btn: Button
var current_node: Node

func _enter_tree() -> void:
	## Add the editor dock
	var dock_scene = preload("res://addons/csg_builder/managers/settings_dock.tscn").instantiate()

	# Create the dock and add the loaded scene to it.
	dock = EditorDock.new()
	dock.add_child(dock_scene)

	dock.title = "Better CSG"

	# Note that LEFT_UL means the left of the editor, upper-left dock.
	dock.default_slot = EditorDock.DOCK_SLOT_LEFT_BL

	# Allow the dock to be on the left or right of the editor, and to be made floating.
	dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_FLOATING

	add_dock(dock)
	
	## Add the context-aware button
	toggle_locked_btn = Button.new()
	toggle_locked_btn.text = "Locked"
	toggle_locked_btn.toggled.connect(_on_button_toggled)
	toggle_locked_btn.hide()
	
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, toggle_locked_btn)

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_dock(dock)
	# Erase the control from the memory.
	dock.queue_free()
	
	if toggle_locked_btn:
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, toggle_locked_btn)
		toggle_locked_btn.queue_free()

func _handles(object):
	return object is Constraint

func _edit(object):
	current_node = object

func _make_visible(visible):
	if current_node is Constraint:
		if toggle_locked_btn:
			toggle_locked_btn.visible = visible
			if visible and current_node:
				# Sync button state with the node's actual state
				toggle_locked_btn.button_pressed = (current_node as Constraint).locked

func _on_button_toggled(toggled_on: bool):
	if current_node:
		if current_node is Constraint:
			(current_node as Constraint).locked = toggled_on

func _handles_input() -> bool:
	return true
