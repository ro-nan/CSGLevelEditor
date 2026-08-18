@tool
class_name EqualToConstraint extends Constraint

@export var target : Node3D
@export var snap_range := 0.0
@export var snap_enabled := true

func _constraint_process(delta: float) -> void:
	if target == null: return
	if snap_range == 0.0:
		parent.global_position = target.global_position
	elif target.global_position.distance_to(parent.global_position) < snap_range and snap_enabled:
		parent.global_position = target.global_position
		
