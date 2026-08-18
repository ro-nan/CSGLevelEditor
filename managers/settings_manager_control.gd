@tool
extends Control

@onready var main_settings: HSplitContainer = $VBoxContainer/MainSettings
@onready var grid_size: SpinBox = $VBoxContainer/MainSettings/R/GridSize

func _process(delta: float) -> void:
	main_settings.split_offset = size.x / 2.0
	
	SettingsManager.tile_size = grid_size.value
