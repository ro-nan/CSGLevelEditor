@tool
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var main_settings: HSplitContainer = $VBoxContainer/MainSettings
@onready var grid_size: SpinBox = $VBoxContainer/MainSettings/R/GridSize

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	main_settings.split_offset = size.x / 2.0
	
	SettingsManager.tile_size = grid_size.value
