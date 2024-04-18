extends Line2D


var _points: Array = []
export var size = 30
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	#_points.push_front(get_viewport().get_mouse_position())
	_points.push_front(get_parent().get_node("LittleJelly").global_position)
	if len(_points)>size:
		_points.pop_back()
	clear_points()
	points = _points
