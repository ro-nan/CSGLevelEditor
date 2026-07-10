@tool
class_name Handle extends Node3D ## I would use Node3DGizmo but I need individual properties for each handle so there

func _ready() -> void:
	if is_instance_valid(get_tree()):	await get_tree().process_frame
	for i in get_children().filter(func(x): return x.name.contains("Label")):
		i.queue_free.call_deferred()
	
	var label = Label3D.new()
	add_child(label)
	label.text = name.remove_chars("Handle")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
