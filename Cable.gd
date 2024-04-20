extends Node2D
class_name Cable

var cable_id = -1

func _ready():
	pass
	
func update_cable(point: int, position: Vector2):
	$Path2D.curve.set_point_position(point, position)
	if true:
		var midpoint = Vector2(
			($Path2D.curve.get_point_position(0).x + $Path2D.curve.get_point_position(2).x)/2,
			max($Path2D.curve.get_point_position(0).y, $Path2D.curve.get_point_position(2).y) + 50
			)
		$Path2D.curve.set_point_position(1, midpoint)
	$Path2D/Line2D.points = $Path2D.curve.get_baked_points() 



func set_cable(position1: Vector2, position2: Vector2, flip: bool):
	if not flip:
		$Path2D.curve.set_point_position(0, position1)
		$Path2D.curve.set_point_position(2, position2)
	else:
		$Path2D.curve.set_point_position(0, position2)
		$Path2D.curve.set_point_position(2, position1)
		
	if true:
		var midpoint = Vector2(
			($Path2D.curve.get_point_position(0).x + $Path2D.curve.get_point_position(2).x)/2,
			max($Path2D.curve.get_point_position(0).y, $Path2D.curve.get_point_position(2).y) + 50
			)
		$Path2D.curve.set_point_position(1, midpoint)
	$Path2D/Line2D.points = $Path2D.curve.get_baked_points() 

