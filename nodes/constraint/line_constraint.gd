@tool
class_name LineConstraint extends Constraint

@export var point1 : Handle
@export var p1_min_dist : float

@export var point2 : Handle
@export var p2_min_dist : float

@export var proportion : float = 0.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _constraint_process(delta: float) -> void:
	if is_instance_valid(point1) and is_instance_valid(point2):
		parent.global_position = (point1.global_position*(1-proportion) + point2.global_position*proportion)
