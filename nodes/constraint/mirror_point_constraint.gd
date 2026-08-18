@tool
class_name MirrorOverPointConstraint extends Constraint

@export var target_point : Node3D

@export var mirror_point : Node3D

func _constraint_process(delta: float) -> void:
	if is_instance_valid(target_point) and is_instance_valid(mirror_point):
		parent.position = mirror_point.global_position - target_point.global_position
