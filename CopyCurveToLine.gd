extends Line2D

func _ready():
	points = get_parent().curve.get_baked_points() 
