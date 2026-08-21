@tool
class_name Handle extends Marker3D

@export var conform_to_grid := true

func _ready() -> void:
	if is_instance_valid(get_tree()):	await get_tree().process_frame
	for i in get_children().filter(func(x): return x.name.contains("Label")):
		i.queue_free.call_deferred()

func handle_process(delta : float) -> void:
	if conform_to_grid:	global_position = lerp(global_position, round(global_position / SettingsManager.tile_size) * SettingsManager.tile_size, delta * 30)

func _process(delta: float) -> void:
	handle_process(delta)
