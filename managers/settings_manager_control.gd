@tool
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var h_split_container: HSplitContainer = $HSplitContainer
@onready var grid_size: SpinBox = $HSplitContainer/R/GridSize

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	h_split_container.split_offset = size.x / 2.0
	
	SettingsManager.tile_size = grid_size.value
