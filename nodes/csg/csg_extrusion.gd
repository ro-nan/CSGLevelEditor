@tool
class_name CSGExtrusion extends AdvancedCSGPolygon

func _update_handles():
	var to = handles[0]
	
	# Build polygon
	polygon.clear()
	var p : Array[Vector2]
	for i in handles.slice(1):
		p.append(Vector2(i.position.x, i.position.y))
	polygon = PackedVector2Array(p)
	
	var x := Array(polygon).map(func(x): return x.x)
	var y := Array(polygon).map(func(x): return x.y)
	if to is PathHandle:
		mode = CSGPolygon3D.MODE_PATH
		path_node = (to as PathHandle).path.get_path()
	elif to.position.x > x.max() or to.position.x < x.min() or to.position.y > y.max() or to.position.y < y.min() or to.position.z >= 0.0:
		mode = CSGPolygon3D.MODE_SPIN
		spin_degrees = 360 + rad_to_deg(atan2(-to.position.z, to.position.x)) if sign(rad_to_deg(atan2(-to.position.z, to.position.x))) == -1 else rad_to_deg(atan2(-to.position.z, to.position.x))
		print(spin_degrees)
	else:
		mode = CSGPolygon3D.MODE_DEPTH
		depth = -to.position.z
	
