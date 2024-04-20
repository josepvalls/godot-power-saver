extends Node2D

# creation
export (PackedScene) var cable_scene
export (PackedScene) var cable_end_scene



export var num_cables = 3
var cable_spacing = Vector2(100, 20)
# runtime
var dragging: CableEnd = null
var cables = {}
var active_port: PlugPort = null

func _ready():
	var cable_instance = $Cable
	var cable_end_instance = $Draggable
	var port_instance = $PlugPort
	
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

		cables[end1] = [cable, end2, false]
		cables[end2] = [cable, end1, true]
		

		add_child(end1)
		end1.connect("clicked", self, "start_drag")
		add_child(end2)
		end2.connect("clicked", self, "start_drag")
		add_child(cable)
	for idx in num_cables:
		var port = port_instance.duplicate() as PlugPort
		port.global_position= Vector2(randf()*get_viewport_rect().size.x, randf()*get_viewport_rect().size.y)
		port.get_node("Area2D").connect("mouse_entered", self, "switch_active_port", [port])
		port.get_node("Area2D").connect("mouse_exited", self, "switch_active_port", [null])

		add_child(port)

func switch_active_port(port: PlugPort):
	active_port = port


func start_drag(source: CableEnd):
	print("start dragging "+str(source.cable_id))
	dragging = source
	
	
func _process(delta):
	if dragging != null:
		dragging.global_position = get_viewport().get_mouse_position()
		var cable_data= cables[dragging]
		cable_data[0].set_cable(dragging.global_position, cable_data[1].global_position, cable_data[2])


func _unhandled_input(event):
	if dragging!= null and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		print("stop dragging "+str(dragging.cable_id))
		get_tree().set_input_as_handled()
		if active_port!=null:
			dragging.global_position = active_port.global_position
			var cable_data= cables[dragging]
			cable_data[0].set_cable(dragging.global_position, cable_data[1].global_position, cable_data[2])

			
			
			
		dragging = null
