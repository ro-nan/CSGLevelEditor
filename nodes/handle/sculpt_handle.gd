@tool
class_name SculptHandle extends Handle

@export var max_effect_range := 0.05
@export var max_effect := 1.0
@export var min_effect := 1.0
@export var effect_curve : Curve = Curve.new()

func get_point_effect(distance : float) -> float:
	var s : float = effect_curve.sample(distance/max_effect_range)
	return min_effect * (1-s) + max_effect * s
