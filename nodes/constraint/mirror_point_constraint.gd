@tool
class_name MirrorOverPointConstraint extends Constraint

@export var target_point : Node3D

@export var mirror_point : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _constraint_process(delta: float) -> void:
	if is_instance_valid(target_point) and is_instance_valid(mirror_point):
		parent.position = mirror_point.global_position - target_point.global_position
