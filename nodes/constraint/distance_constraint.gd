@tool
class_name DistanceConstraint extends Constraint

enum MODE {
	CIRCULAR,
	CUBE
}

@export var target : Node3D
@export var distance_mode : MODE
@export var general_distance : float
@export var cube_distance : Vector3

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	
	var t_pos = target.global_position
	var offset = parent.global_position - t_pos
	
	match distance_mode:
		MODE.CIRCULAR:
			if offset.length() > 0:
				parent.global_position = offset.normalized() * general_distance + t_pos
		
		MODE.CUBE:
			var constrained_offset = offset
			
			# Constrain each axis independently if cube_distance component is non-zero
			if not is_zero_approx(cube_distance.x):
				constrained_offset.x = clamp(offset.x, -abs(cube_distance.x), abs(cube_distance.x))
			if not is_zero_approx(cube_distance.y):
				constrained_offset.y = clamp(offset.y, -abs(cube_distance.y), abs(cube_distance.y))
			if not is_zero_approx(cube_distance.z):
				constrained_offset.z = clamp(offset.z, -abs(cube_distance.z), abs(cube_distance.z))
			
			parent.global_position = constrained_offset + t_pos
