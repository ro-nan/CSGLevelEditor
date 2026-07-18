@tool
class_name AdvancedMultimeshPlacer extends AdvancedMultimesh

@export var mesh : Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_handles_square()
	
	multimesh = MultiMesh.new()
	
	multimesh.transform_format = MultiMesh.TRANSFORM_3D


func _update_handles():
	multimesh.instance_count = len(handles)
	multimesh.mesh = mesh

	for i in range(len(handles)):
		var handle = handles[i]
		
		multimesh.set_instance_transform(i, handle.transform)
		
