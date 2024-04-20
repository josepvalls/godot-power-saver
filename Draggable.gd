extends Area2D
class_name CableEnd


var mouse_over = false
var cable_id = -1

signal clicked(source)

func _ready():
	connect("mouse_entered", self, "_mouse_over", [true])
	connect("mouse_exited", self, "_mouse_over", [false])

	set_process_unhandled_input(true)

func _unhandled_input(event):
	if mouse_over and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().set_input_as_handled()
		print("clicked")
		emit_signal("clicked", self)

func _mouse_over(value):
	self.mouse_over = value
