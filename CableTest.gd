extends Node2D

# creation
export (PackedScene) var cable_scene
export (PackedScene) var cable_end_scene



export var num_cables = 3
var cable_spacing = Vector2(100, 20)
# runtime
var dragging: CableEnd = null

func _ready():
	var cable_instance = $Cable
	var cable_end_instance = $Draggable
	
	# avoid piling everything
	var current_position = cable_spacing
	for idx in num_cables:
		#var end1 := cable_end_scene.instance() as CableEnd
		var end1 := cable_end_instance.duplicate() as CableEnd
		end1.global_position = current_position
		current_position += cable_spacing

		#var end2 := cable_end_scene.instance() as CableEnd
		var end2 := cable_end_instance.duplicate() as CableEnd
		end2.global_position = current_position
		current_position += cable_spacing

		#var cable := cable_scene.instance() as Cable
		var cable := cable_instance.duplicate() as Cable

		cable.cable_id = idx
		end1.cable_id = idx
		end2.cable_id = idx
		
		var cable_color = Color(randf(), randf(), 1, 1)
		cable.modulate = cable_color
		end1.modulate = cable_color
		end2.modulate = cable_color

		end1.bound_to = cable
		end1.bound_to_point = 0
		end2.bound_to = cable
		end2.bound_to_point = 2

		add_child(end1)
		end1.connect("clicked", self, "start_drag")
		add_child(end2)
		end2.connect("clicked", self, "start_drag")
		add_child(cable)



func start_drag(source: CableEnd):
	print("start dragging "+str(source.cable_id))
	dragging = source
	
	
func _process(delta):
	if dragging != null:
		dragging.global_position = get_viewport().get_mouse_position()
		#dragging.bound_to.update_cable(dragging.bound_to_point, dragging.bound_to.get_node("Path2D").to_local(dragging.global_position))
		
		
		

func _unhandled_input(event):
	if dragging!= null and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		print("stop dragging "+str(dragging.cable_id))
		get_tree().set_input_as_handled()
		print("update cable "+str(dragging.bound_to.cable_id))
		dragging.bound_to.update_cable(dragging.bound_to_point, dragging.global_position)
		dragging = null
