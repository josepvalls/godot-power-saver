extends Node2D
class_name Cable

var cable_id = -1

var cable_jitter = 0
var cable_jitter_delta = 25
var cable_jitter_max = 25

func _ready():
	pass
	
func _process(delta):
	
	cable_jitter += cable_jitter_delta * delta
	if abs(cable_jitter) > cable_jitter_max:
		cable_jitter_delta*= -1
	
	
func update_cable(point: int, position: Vector2):
	$Path2D.curve.set_point_position(point, position)
	if true:
		var midpoint = Vector2(
			($Path2D.curve.get_point_position(0).x + $Path2D.curve.get_point_position(2).x)/2,
			max($Path2D.curve.get_point_position(0).y, $Path2D.curve.get_point_position(2).y) + 50
			)
		$Path2D.curve.set_point_position(1, midpoint)
	$Path2D/Line2D.points = $Path2D.curve.get_baked_points() 


func jitter():
	#return
	#$Path2D.curve.set_point_in(1, $Path2D.curve.get_point_in(1)+Vector2(randi()%50, 0)-Vector2(25,0)) 
	#$Path2D.curve.set_point_out(1, $Path2D.curve.get_point_out(1)+Vector2(randi()%50, 0)-Vector2(25,0)) 
	$Path2D.curve.set_point_in(1, Vector2(-cable_jitter-cable_jitter_max, 0)) 
	$Path2D.curve.set_point_out(1, Vector2(+cable_jitter+cable_jitter_max, 0)) 


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
		jitter()
	$Path2D/Line2D.points = $Path2D.curve.get_baked_points() 

