extends Node2D


var girl_at = 0
var girl_left = Vector2(-500,320)
var girl_right = Vector2(1300,320)

var light_on = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$Switch/Area2D.connect("input_event", self, "switch_click")
	call_deferred("move_girl")


func switch_click( camera, event: InputEvent, position):
	if event.is_pressed():
		$Switch/Actuator.rotation_degrees += 180
		if light_on:
			$Light.hide()
			$CanvasModulate.show()
			get_tree().call_group("shadows", "hide")
			light_on=false
		else:
			$Light.show()
			$CanvasModulate.hide()
			get_tree().call_group("shadows", "show")
			light_on=true

func _process(delta):
	#var pos = get_viewport().get_mouse_position()
	#$Box.global_position = pos
	#var l = $Path2D3.curve.get_point_count()
	#$Path2D3.curve.set_point_position(l-1, pos-$Path2D3.global_position)
	#$Path2D3/AntialiasedLine2D.points = $Path2D3.curve.get_baked_points() 

	# flicker
	var screen: Light2D = $Lights.get_child(randi()%$Lights.get_child_count())
	screen.energy = 0.5+randf()/2
	
func move_girl():
	var move_time = 5
	if girl_at == 0:
		$Girl.flip_h = 0
		$Tween.interpolate_property($Girl, "global_position", girl_left, girl_right, move_time)
		girl_at = 1
	else:
		$Girl.flip_h = 1
		$Tween.interpolate_property($Girl, "global_position", girl_right, girl_left, move_time)
		girl_at = 0
	$Tween.interpolate_deferred_callback(self,  move_time*2, "move_girl")
	$Tween.start()
