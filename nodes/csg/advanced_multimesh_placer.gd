@tool
class_name AdvancedMultimeshPlacer extends AdvancedMultimesh

@export var mesh : Mesh
@export_group("Instance Transform Modifer")
 ## Adds this transform to the transform of each of the nodes so you can perform operations on all mesh instances at once. 
@export var instance_transform_modifer_position : Vector3
@export var instance_transform_modifer_rotation : Vector3
@export var instance_transform_modifer_scale : Vector3

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
		
