extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Start.position = $Path2D.curve.get_point_position(0)
	$End.position = $Path2D.curve.get_point_position(3)


