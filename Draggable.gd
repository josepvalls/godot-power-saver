extends Area2D


var mouse_over = false

func _ready():
	connect("mouse_entered", self, "_mouse_over", [true])
	connect("mouse_exited", self, "_mouse_over", [false])

	set_process_unhandled_input(true)

func _unhandled_input(event):
	if mouse_over and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().set_input_as_handled()
		print("clicked")

func _mouse_over(value):
	self.mouse_over = value
