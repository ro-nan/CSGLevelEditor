@tool
class_name DistanceConstraint extends Constraint

enum DISTANCE_MODE {
	CIRCULAR, ## The distance from the parent of this constraint to the target of this constraint is equal to `general_distance`
	CUBE ## The distance from the parent and the target is equal to +- cube_distance for each of x, y, and z unless it equals 0.0
}

enum VALUE_MODE {
	EQUAL,
	OUTSIDE,
	INSIDE
}

@export var target : Node3D
@export var distance_mode : DISTANCE_MODE
@export var value_mode : VALUE_MODE
@export var general_distance : float
@export var cube_distance : Vector3

func _ready() -> void:
	pass

func _constraint_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	
	var t_pos = target.global_position
	var offset = parent.global_position - t_pos
	
	match distance_mode:
		DISTANCE_MODE.CIRCULAR:
			if offset.length() > 0:
				parent.global_position = offset.normalized() * general_distance + t_pos
		
		DISTANCE_MODE.CUBE:
			var constrained_offset = offset
			
			match value_mode:
					VALUE_MODE.EQUAL:
						if not is_zero_approx(cube_distance.x):
							constrained_offset.x = sign(offset.x) * abs(cube_distance.x)
						if not is_zero_approx(cube_distance.y):
							constrained_offset.y = sign(offset.y) * abs(cube_distance.y)
						if not is_zero_approx(cube_distance.z):
							constrained_offset.z = sign(offset.z) * abs(cube_distance.z)
					
					VALUE_MODE.OUTSIDE:
						if not is_zero_approx(cube_distance.x):
							constrained_offset.x = sign(offset.x) * max(abs(offset.x), abs(cube_distance.x))
						if not is_zero_approx(cube_distance.y):
							constrained_offset.y = sign(offset.y) * max(abs(offset.y), abs(cube_distance.y))
						if not is_zero_approx(cube_distance.z):
							constrained_offset.z = sign(offset.z) * max(abs(offset.z), abs(cube_distance.z))
					
					VALUE_MODE.INSIDE:
						if not is_zero_approx(cube_distance.x):
							constrained_offset.x = clamp(offset.x, -abs(cube_distance.x), abs(cube_distance.x))
						if not is_zero_approx(cube_distance.y):
							constrained_offset.y = clamp(offset.y, -abs(cube_distance.y), abs(cube_distance.y))
						if not is_zero_approx(cube_distance.z):
							constrained_offset.z = clamp(offset.z, -abs(cube_distance.z), abs(cube_distance.z))
			
			parent.global_position = constrained_offset + t_pos
