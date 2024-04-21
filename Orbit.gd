extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var radius = 100.0
var elapsed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	elapsed += delta * 2
	$Jelly.position = Vector2(cos(elapsed)*radius, cos(elapsed)*sin(elapsed)*radius)
