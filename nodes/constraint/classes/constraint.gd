class_name Constraint extends Node

var parent : Node3D :
	get():
		return get_parent()

@export var locked := false

func _process(delta: float) -> void:
	if !locked:	_constraint_process(delta)

func _constraint_process(delta: float) -> void:
	pass
