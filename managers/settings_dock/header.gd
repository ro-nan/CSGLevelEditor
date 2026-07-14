@tool
extends Panel

@export var icon : Texture2D
@export var text : String 

@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var label: Label = $HBoxContainer/Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	texture_rect.texture = icon
	label.text = text
