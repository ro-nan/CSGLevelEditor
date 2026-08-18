@tool
class_name FacingConstraint extends Constraint

@export var target : Node3D
@export var up : Vector3i = Vector3.UP
@export var use_mdl_front : bool = false

func _constraint_process(delta: float) -> void:
	if is_instance_valid(target):
		parent.look_at(target.global_position, up, use_mdl_front)
