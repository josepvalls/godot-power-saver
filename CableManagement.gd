extends Node2D

var little_jelly_elapsed = 0
var little_jelly_target = null
var little_jelly_need_attention = {}


var girl_at = 0
var girl_left = Vector2(-250,320)
var girl_right = Vector2(1250,320)
var girl_move_time = 5.0
var girl_visible = true
var girl_moving = false

export(AudioStream) var switch_on
export(AudioStream) var switch_off
export(AudioStream) var music_on
export(AudioStream) var music_off
var music_volume = 1.0


var light_on = true
var is_music_on = true

var intro_talking_time = 5
var current_intro = 1
var intro_slides = 5
var current_level = 0

var current_state = "intro"
var state_transitions = {
	"intro": "flying",
	"flying": "playing",
	"playing": "game_over",
	"game_over": "intro"
	}

var current_power = 0.0
var current_happiness = 0.0

var current_hotspot = "screen2"
var update_elapsed = 0.0
var update_interval = 0.5

var levels = [
	 #0
	{},
	#1
	{
		"pc1":[true, true, -5, -5],
		"pc2":[true, true, -5, -5],
		"screen1":[true, true, 5, 4],
		"screen2":[true, true, 4, 2],
	},
	{
		"pc1":[true, true, -5, -5],
		"pc2":[true, true, -5, -5],
		"screen1":[true, true, 5, 4],
		"screen2":[true, true, 4, 2],
		"mp3": [true, true, 10,2]
	},
	{
		"pc1":[true, true, -5, -5],
		"pc2":[true, true, -5, -5],
		"screen1":[true, true, 5, 4],
		"screen2":[true, true, 4, 2],
		"mp3": [true, true, 10,2],
		"phone": [true, true, 1,2]
	},
	{
		"pc1":[true, true, -5, -5],
		"pc2":[true, true, -5, -5],
		"screen1":[true, true, 5, 4],
		"screen2":[true, true, 4, 2],
		"mp3": [true, true, 4,2],
		"phone": [true, true, 1,2]
	},
	{
		"pc1":[true, true, -5, -5],
		"pc2":[true, true, -5, -5],
		"screen1":[true, true, 5, 4],
		"screen2":[true, true, 4, 2],
		"mp3": [true, true, 4,2],
		"phone": [true, true, 4,3],
		"tablet3": [true, true, 4,4],
	},
	{
		"pc1":[true, true, -5, -5],
		"pc2":[true, true, -5, -5],
		"screen1":[true, true, 5, 4],
		"screen2":[true, true, 4, 2],
		"mp3": [true, true, 4,2],
		"phone": [true, true, 4,3],
		"tablet2": [true, true, 4,4],
	},
	{
		"pc1":[true, true, -5, -5],
		"pc2":[true, true, -5, -5],
		"screen1":[true, true, 5, 4],
		"screen2":[true, true, 4, 2],
		"mp3": [true, true, 4,2],
		"phone": [true, true, 4,3],
		"tablet2": [true, true, 4,4],
		"tablet3": [true, true, -1,4],
	},	
	{
		"pc1":[true, true, -5, -5],
		"pc2":[true, true, -5, -5],
		"screen1":[true, true, 5, 4],
		"screen2":[true, true, 4, 2],
		"mp3": [true, true, 4,2],
		"phone": [true, true, 4,3],
		"tablet1": [true, true, -1,4],
		"tablet2": [true, true, 4,4],
		"tablet3": [true, true, -1,4],
	},
	{
		"pc1":[true, true, -5, -5],
		"pc2":[true, true, -5, -5],
		"screen1":[true, true, 5, 4],
		"screen2":[true, true, 4, 2],
		"mp3": [true, true, 4,2],
		"phone": [true, true, 4,3],
		"tablet1": [true, true, -1,4],
		"tablet2": [true, true, 4,4],
		"tablet3": [true, true, -1,4],
		"remote": [true, true, -1,4],
	},
	{
		"pc1":[true, true, -5, -5],
		"pc2":[true, true, -5, -5],
		"screen1":[true, true, 5, 4],
		"screen2":[true, true, 4, 2],
		"mp3": [true, true, -1,2],
		"phone": [true, true, 4,3],
		"tablet1": [true, true, -1,4],
		"tablet2": [true, true, 4,4],
		"tablet3": [true, true, 6,4],
		"remote": [true, true, -1,4],
		"pda": [true, true, 3,4],
		"cassette": [true, true, -1,4],
	}
	# ^ this is 10 levels
]

# cables
var cable_instance: Cable = null
var cable_end_instance: CableEnd = null
var dragging: CableEnd = null
var cables = {}
var ports = {}
var active_port: Hotspot = null
var color_power: Color = Color("000000")# Color("ffff61")
var color_plug: Color = Color("000000")# Color("0091ff")
var color_none: Color = Color("000000")

func create_cables():
	create_cable(ports["power3"], ports["mp3"])
	create_cable(ports["tablet1"], ports["power4"])
	create_cable(ports["power5"], ports["phone"])
	create_cable(ports["power6"], ports["cassette"])
	create_cable(ports["power7"], ports["power2"])

func create_cable(from: Hotspot, to: Hotspot):
	print("creating cable from "+from.uid+" to "+to.uid)
	var end1 := cable_end_instance.duplicate() as CableEnd
	end1.global_position = from.port_position
	end1.show()
	end1.plugged_hotspot = from

	var end2 := cable_end_instance.duplicate() as CableEnd
	end2.global_position = to.port_position
	end2.show()
	end2.plugged_hotspot = to

	var cable := cable_instance.duplicate() as Cable
	cable.show()
	
	cables[end1] = [cable, end2, false]
	cables[end2] = [cable, end1, true]
	

	$Cables.add_child(cable)
	$Cables.add_child(end1)
	end1.connect("clicked", self, "start_drag")
	$Cables.add_child(end2)
	end2.connect("clicked", self, "start_drag")
	
	
	refresh_cable(end1)

func refresh_cable(cable_end: CableEnd):
	var cable_data= cables[cable_end]
	cable_data[0].set_cable(cable_end.global_position, cable_data[1].global_position, cable_data[2])
	var color1 = color_none
	var color2 = color_none
	var has_power = false
	var needs_power1: Hotspot = null
	var needs_power2: Hotspot = null
	#print("refreshing cable from "+str(cable_end.plugged_hotspot)+" to "+str(cable_data[1].plugged_hotspot))
	if cable_end.plugged_hotspot!=null:
		#print("refreshing cable from "+cable_end.plugged_hotspot.uid+" "+str(cable_end.plugged_hotspot.power_provider))
		if cable_end.plugged_hotspot.power_provider:
			color1 = color_power
			has_power = true
		else:
			color1 = color_plug
			needs_power1 = cable_end.plugged_hotspot
	if cable_data[1].plugged_hotspot!=null:
		#print("refreshing cable from "+cable_data[1].plugged_hotspot.uid+" "+str(cable_data[1].plugged_hotspot.power_provider))
		if cable_data[1].plugged_hotspot.power_provider:
			color2 = color_power
			has_power = true
		else:
			color2 = color_plug
			needs_power2 = cable_data[1].plugged_hotspot
	if has_power:
		if needs_power1!=null:
			needs_power1.is_plugged = true
		if needs_power2!=null:
			needs_power2.is_plugged = true
	else:
		if needs_power1!=null:
			needs_power1.is_plugged = false
		if needs_power2!=null:
			needs_power2.is_plugged = false

	cable_data[0].color_cable(color1, color2, cable_data[2])


func switch_active_port(port: Hotspot):
	active_port = port



func start_drag(source: CableEnd):
	print("start dragging "+str(source.cable_id))
	dragging = source
	if dragging.plugged_hotspot != null:
		dragging.plugged_hotspot.is_plugged = false
	dragging.plugged_hotspot = null
	refresh_cable(dragging)

# Devices

func hotspot_to_status(hotspot: Hotspot):
	$CanvasLayer/ControlPopup/Status1.text = hotspot.status_str_1
	$CanvasLayer/ControlPopup/Status2.text = hotspot.status_str_2
	$CanvasLayer/ControlPopup/Powered.pressed = hotspot.is_on
	$CanvasLayer/ControlPopup/Idle.value = hotspot.idle_percent
	if hotspot.is_in_stand_by:
		$CanvasLayer/ControlPopup/Idle.theme_type_variation = "ProgressBar"
		#$CanvasLayer/ControlPopup/Idle["theme_overrides/fg"].bg_color = Color(0,1,0,1)
	else:
		$CanvasLayer/ControlPopup/Idle.theme_type_variation = "UseProgressBar"
	if hotspot.uses_battery:
		$CanvasLayer/ControlPopup/Battery.show()
		$CanvasLayer/ControlPopup/ACPower.hide()
		$CanvasLayer/ControlPopup/Battery.value = hotspot.battery_level * 100
	else:
		$CanvasLayer/ControlPopup/Battery.hide()
		$CanvasLayer/ControlPopup/ACPower.show()
		
	
func click_power():
	var num_on = 0.0
	var num_total = 0.0
	var is_speaker_on = true
	for item in $Lights.get_children():
		var hotspot: Hotspot = item.get_node("Hotspot")
		num_total += 1
		if hotspot.uid == current_hotspot:
			hotspot.do_toggle()
			update_statuses(0)
		# check for status after toggling
		if hotspot.is_on:
				num_on += 1
		if hotspot.is_speaker:
			is_speaker_on = hotspot.is_on

	if is_speaker_on != is_music_on:
		if is_speaker_on:
			$CanvasLayer/AudioStreamPlayer.stream = music_on
			$CanvasLayer/AudioStreamPlayer.volume_db = linear2db(music_volume)
			$CanvasLayer/AudioStreamPlayer.play()
			is_music_on = true
		else:
			$CanvasLayer/AudioStreamPlayer.stream = music_off
			$CanvasLayer/AudioStreamPlayer.volume_db = linear2db(1.0 * num_on / num_total) + 2
			$CanvasLayer/AudioStreamPlayer.play()
			is_music_on = false
		

func update_statuses(delta):
	if current_state=="playing":
		update_elapsed += delta
	if update_elapsed >= update_interval:
		#var fps = Engine.get_frames_per_second()
		#OS.set_window_title("fps: " + str(fps))

		var tick_happiness = 0.0
		update_elapsed = 0	
		current_power = 0.0
		
		if light_on:
			current_power += 60
		
		for item in $Lights.get_children():
			var hotspot: Hotspot = item.get_node("Hotspot")
			hotspot.refresh_status(update_interval)
			if hotspot.uid == current_hotspot:
				hotspot_to_status(hotspot)
			#print(hotspot.print_status())
			
			if hotspot.is_on:
				current_power += hotspot.power_use
				
			if hotspot.needs_attention:
				little_jelly_need_attention[hotspot] = true
			elif little_jelly_need_attention.has(hotspot):
				little_jelly_need_attention.erase(hotspot)
			
			tick_happiness += hotspot.current_happiness
				
		# bonuses
		if current_level<len(levels):
			if tick_happiness>=len(levels[current_level])*0.1:
				tick_happiness += 1
		
		if girl_visible and light_on or not girl_visible and not light_on:
			tick_happiness += 1
		elif girl_moving and not girl_visible:
			# be nice, do not discount here
			pass
		else:
			tick_happiness -= 1

	
		current_happiness += tick_happiness
		$CanvasLayer/Score/ScoreDelta.show()
		$CanvasLayer/Score/ScoreDelta.text = ("+" if tick_happiness >0 else "") + "%.2f" % tick_happiness
		$CanvasLayer/Score/Score.text = "%.2f" % current_happiness
		$CanvasLayer/Score/Power.text = str(current_power) + " Watt/h"
		$CanvasLayer/Score.modulate
		$CanvasLayer/Score/Tween.interpolate_property($CanvasLayer/Score/ScoreDelta, "rect_position", Vector2(868,28), Vector2(868,0), update_interval, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$CanvasLayer/Score/Tween.interpolate_property($CanvasLayer/Score/ScoreDelta, "modulate", Color(1,1,1,1), Color(1,1,1,0), update_interval, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$CanvasLayer/Score/Tween.start()
		
		little_jelly_consider_retargetting()

func do_retry():
	get_tree().change_scene("res://Table.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	cable_instance = $Cable
	cable_end_instance = $Draggable
	call_deferred("create_cables")
	
	$Switch/Area2D.connect("input_event", self, "click_switch")
	
	var idx = 1
	for item in $Lights.get_children():
		var hotspot: Hotspot = item.get_node("Hotspot")
		if hotspot:
			hotspot.uid = hotspot.get_parent().name
			#idx += 1
			if hotspot.uses_battery:
				ports[hotspot.uid] = hotspot
				var plug = hotspot.get_parent().get_node("Position2D")
				if plug == null:
					hotspot.port_position = hotspot.global_position + Vector2(0,60)
				else:
					hotspot.port_position = plug.global_position
				hotspot.connect("mouse_entered", self, "switch_active_port", [hotspot])
				hotspot.connect("mouse_exited", self, "switch_active_port", [null])
				
			hotspot.connect("input_event", self, "click_hotspot", [hotspot])

	for item in $Power.get_children():
		var hotspot:= item as Hotspot
		if hotspot:
			hotspot.uid = "power"+str(idx)
			hotspot.port_position = hotspot.global_position
			ports[hotspot.uid] = hotspot
			hotspot.connect("mouse_entered", self, "switch_active_port", [hotspot])
			hotspot.connect("mouse_exited", self, "switch_active_port", [null])

			idx += 1


	$CanvasLayer/Score/ScoreDelta.hide()
	$Girl.hide()
	$Girl.animation = "idle"
	$CanvasLayer/ControlPopup.hide()
	
	$CanvasLayer/ControlPopup/Powered.connect("pressed", self, "click_power")
	$Tween.stop_all()
	$CanvasLayer/Tween.interpolate_property($CanvasLayer/Intro1/Control/Label, "percent_visible", 0, 1.0, intro_talking_time)
	$CanvasLayer/Tween.interpolate_callback(self, intro_talking_time, "do_stop_talking")
	$CanvasLayer/Tween.start()
	$CanvasLayer/Intro1/Control/Button.connect("pressed", self, "do_next_tutorial")
	$CanvasLayer/Intro2/Control/Button.connect("pressed", self, "do_next_tutorial")
	$CanvasLayer/Intro3/Control/Button.connect("pressed", self, "do_next_tutorial")
	$CanvasLayer/Intro4/Control/Button.connect("pressed", self, "do_next_tutorial")
	$CanvasLayer/Intro5/Control/Button.connect("pressed", self, "do_next_tutorial")
	$CanvasLayer/Score/Retry.connect("pressed", self, "do_retry")
	
	
	$CanvasLayer/AudioStreamPlayer.stream = music_on
	$CanvasLayer/AudioStreamPlayer.volume_db = linear2db(music_volume)
	$CanvasLayer/AudioStreamPlayer.play()
	
	$Background/GirlVisible.connect("area_entered", self, "girl_visibility", [true])
	$Background/GirlVisible.connect("area_exited", self, "girl_visibility", [false])
	$Girl/Area2D.connect("area_entered", self, "girl_toggle_level")
	
	for i in range(2,intro_slides+1):
		$CanvasLayer.get_node("Intro" + str(i)).hide()
	$CanvasLayer/Intro1.show()

func girl_visibility(area, girl_state):
	girl_visible = girl_state
	
func girl_toggle_level(area):
	if current_level < len(levels):
		var hotspot := area as Hotspot
		if hotspot != null and hotspot.uid in levels[current_level]:
			print("Toggling "+hotspot.uid)
			hotspot.elapsed = 0
			hotspot.want_to_use = levels[current_level][hotspot.uid][0]
			hotspot.is_on = levels[current_level][hotspot.uid][1]
			hotspot.want_to_use_time = levels[current_level][hotspot.uid][2]
			hotspot.in_stand_by_time = levels[current_level][hotspot.uid][3]
	else:
		var hotspot := area as Hotspot
		if hotspot != null:
			print("Toggling "+hotspot.uid)
			hotspot.elapsed = 0
			if randf()<0.7:
				hotspot.want_to_use = true
				hotspot.is_on = true
				hotspot.want_to_use_time = randi()%10
				hotspot.in_stand_by_time = randi()%10
		
			
func do_talk():
	$Jelly/mouth.playing = true

func do_stop_talking():
	$CanvasLayer/Intro1/Jelly/mouth.playing = false
	$CanvasLayer/Intro1/Jelly/mouth.frame = 2
	$"CanvasLayer/Intro1/Jelly/eye-left".frame = 2
	$"CanvasLayer/Intro1/Jelly/eye-right".frame = 2

func do_next_tutorial():
	print("do_next_tutorial")
	$CanvasLayer.get_node("Intro" + str(current_intro)).hide()
	current_intro += 1
	if current_intro == 2:
		$Girl.show()
	elif current_intro == 3:
		$CanvasLayer/ControlPopup.show()
		$CanvasLayer/ControlPopup/Powered.disabled = true
	elif current_intro == 4:
		$Girl.animation = "walk"
		$Tween.interpolate_property($Girl, "global_position", $Girl.global_position, girl_right, girl_move_time/2)
		$Tween.start()
		girl_at = 1
	elif current_intro == 5:
		$Tween.stop_all()
		$Girl.global_position=girl_right
		girl_stop_sound()
		click_switch(null, null, null)

	if current_intro <= intro_slides:
		var temp_jelly = $CanvasLayer.get_node("Intro" + str(current_intro-1) + "/Jelly").duplicate()
		$CanvasLayer.add_child(temp_jelly)
		var temp_transition_time = 0.3
		$CanvasLayer.get_node("Intro" + str(current_intro) + "/Jelly").hide()
		$CanvasLayer/Tween.interpolate_property(temp_jelly, "global_position", temp_jelly.global_position, $CanvasLayer.get_node("Intro" + str(current_intro) + "/Jelly").global_position, temp_transition_time,Tween.TRANS_CUBIC, Tween.EASE_OUT)                
		$CanvasLayer/Tween.interpolate_property(temp_jelly, "scale", temp_jelly.scale, $CanvasLayer.get_node("Intro" + str(current_intro) + "/Jelly").scale, temp_transition_time,Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$CanvasLayer/Tween.interpolate_callback(temp_jelly, temp_transition_time, "queue_free")
		$CanvasLayer/Tween.interpolate_callback($CanvasLayer.get_node("Intro" + str(current_intro) + "/Jelly"), temp_transition_time, "show")
		$CanvasLayer/Tween.start()
		
		
		$CanvasLayer.get_node("Intro" + str(current_intro)).show()
	else:
		current_state = "playing"
		$CanvasLayer/ControlPopup/Powered.disabled = false
		yield(get_tree().create_timer(8), "timeout")
		girl_move()

func click_hotspot(camera, event: InputEvent, position, hotspot: Hotspot):
	if event.is_pressed():
		if current_state == "playing":
			$CanvasLayer/ControlPopup.show()
			var desired_position = hotspot.global_position + Vector2(0, -120)
			desired_position.x = clamp(desired_position.x, 0, 1024-200)
			desired_position.y = clamp(desired_position.y, 20, 600)
			$CanvasLayer/ControlPopup.set_position(desired_position)
			current_hotspot = hotspot.uid
			hotspot_to_status(hotspot)	
		get_tree().set_input_as_handled()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		print("clicked nowhere")
		if current_state=="playing" and current_hotspot != "":
			#get_tree().set_input_as_handled()
			current_hotspot = ""
			$CanvasLayer/ControlPopup.hide()
	elif dragging!= null and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		print("stop dragging "+str(dragging.cable_id))
		get_tree().set_input_as_handled()
		if active_port!=null:
			dragging.global_position = active_port.port_position
			dragging.plugged_hotspot = active_port
		else:
			dragging.global_position.y = 520
			dragging.plugged_hotspot = null
		refresh_cable(dragging)
		dragging = null

		


func click_switch(camera, event: InputEvent, position):
	if event == null or current_state == "playing" and event.is_pressed():
		if light_on:
			$Switch/On.hide()
			$Switch/Off.show()
			$Switch/AudioStreamPlayer.stream = switch_off
			$Switch/AudioStreamPlayer.play()
			$Light.hide()
			$CanvasModulate.show()
			get_tree().call_group("shadows", "hide")
			light_on=false
		else:
			$Switch/On.show()
			$Switch/Off.hide()
			$Switch/AudioStreamPlayer.stream = switch_on
			$Switch/AudioStreamPlayer.play()
			$Light.show()
			$CanvasModulate.hide()
			get_tree().call_group("shadows", "show")
			light_on=true

func little_jelly_consider_retargetting(suggested_target=null):
	if suggested_target != null:
		little_jelly_target = suggested_target
		little_jelly_elapsed = 0
	else:
		if little_jelly_elapsed > 1.1:
			if len(little_jelly_need_attention)==0:
				if little_jelly_target!=null:
					little_jelly_elapsed = 0
				little_jelly_target = null
				
			else:		
				var new_target = little_jelly_need_attention.keys()[randi()%len(little_jelly_need_attention)]
				if new_target != little_jelly_target:
					little_jelly_target = new_target
					little_jelly_elapsed = 0

func _process(delta):
	# devices
	update_statuses(delta)
	# move to cursor
	if current_state=="playing":
		if ($Girl.global_position - $Switch.global_position).length_squared() < 36000 and not light_on:
			print("girl turns on switch")
			click_switch(null, null, null)
		
		little_jelly_elapsed += delta 
		var center_default_jelly = PI/2 #+ (randi()%2) * PI
		var jelly_target = null
		if little_jelly_target == null:
			#jelly_target = Vector2(cos(little_jelly_elapsed)*100, cos(little_jelly_elapsed)*sin(little_jelly_elapsed)*100) + get_viewport().get_mouse_position() + Vector2(0,-30)
			jelly_target = Vector2(cos(little_jelly_elapsed+center_default_jelly)*500, cos(little_jelly_elapsed+center_default_jelly)*sin(little_jelly_elapsed+center_default_jelly)*100) + get_viewport_rect().size/2 + Vector2(0,-100)
		else:
			jelly_target = Vector2(cos(little_jelly_elapsed+center_default_jelly)*50, cos(little_jelly_elapsed+center_default_jelly)*sin(little_jelly_elapsed+center_default_jelly)*50) + little_jelly_target.global_position
		var vec = jelly_target - $LittleJelly.global_position
		#$LittleJelly.look_at(jelly_target)
		#$LittleJelly.rotation -= PI/4
		#if vec.length() < 100:
		#	$LittleJelly.rotation = lerp(0, $LittleJelly.rotation, vec.length()/100)
		$LittleJelly.global_position = lerp($LittleJelly.global_position, jelly_target, 0.1)
		
		if dragging != null:
			dragging.global_position = get_viewport().get_mouse_position()
			refresh_cable(dragging)

	
func girl_move():
	current_level += 1
	print("Starting level "+str(current_level))
	if current_level == 11:
		$CanvasLayer/Score/Deterministic.text = "Your happiness for the first 10 levels was: " + str(current_happiness) #+ ". Click here to retry."
	elif current_level < 11:
		$CanvasLayer/Score/Deterministic.text = "Play "+str(11-current_level)+" more levels to record your score." #Click here to restart."
	girl_moving = true
	if not light_on:
		print("girl moves and light is off "+str(little_jelly_elapsed))
		little_jelly_consider_retargetting($Switch)
	else:
		print("girl moves and light is on "+str(little_jelly_elapsed))
	$Girl.show()
	$Girl.animation = "walk"
	if girl_at == 0:
		$Girl.flip_h = 0
		$Tween.interpolate_property($Girl, "global_position", girl_left, girl_right, girl_move_time)
		girl_at = 1
	else:
		$Girl.flip_h = 1
		$Tween.interpolate_property($Girl, "global_position", girl_right, girl_left, girl_move_time)
		girl_at = 0
	$Tween.interpolate_deferred_callback(self,  girl_move_time, "girl_stop_sound")
	$Tween.interpolate_deferred_callback(self,  girl_move_time*4, "girl_move")
	$Girl/AudioStreamPlayer.volume_db = 3
	$Girl/AudioStreamPlayer.play()
	$Tween.start()

func girl_stop_sound():
	$Girl/AudioStreamPlayer.stop()
	girl_moving = false

