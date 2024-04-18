extends Node2D


var girl_at = 0
var girl_left = Vector2(-250,320)
var girl_right = Vector2(1250,320)

export(AudioStream) var switch_on
export(AudioStream) var switch_off
export(AudioStream) var music_on
export(AudioStream) var music_off
var music_volume = 0.4


var light_on = true
var is_music_on = true

var intro_talking_time = 5
var current_intro = 1

var current_state = "intro"
var state_transitions = {
	"intro": "flying",
	"flying": "playing",
	"playing": "game_over",
	"game_over": "intro"
	}

var current_power = 0.0
var current_happiness = 0.0

var current_hotspot = -1
var update_elapsed = 0.0
var update_interval = 0.5

var scoring_paused = true

func hotspot_to_status(hotspot: Hotspot):
	$CanvasLayer/ControlPopup/Status1.text = hotspot.status_str_1
	$CanvasLayer/ControlPopup/Status2.text = hotspot.status_str_2
	$CanvasLayer/ControlPopup/Powered.pressed = hotspot.is_on
	$CanvasLayer/ControlPopup/Idle.value = hotspot.idle_percent
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
	if not scoring_paused:
		update_elapsed += delta
	if update_elapsed >= update_interval:
		var tick_happiness = 0.0
		update_elapsed = 0
		var fps = Engine.get_frames_per_second()
		OS.set_window_title("fps: " + str(fps))
		
		current_power = 0.0
		
		for item in $Lights.get_children():
			var hotspot: Hotspot = item.get_node("Hotspot")
			hotspot.refresh_status(update_interval)
			if hotspot.is_on:
				current_power += hotspot.power_use
			tick_happiness += hotspot.current_happiness
			if hotspot.uid == current_hotspot:
				hotspot_to_status(hotspot)
	
		current_happiness += tick_happiness
		$CanvasLayer/Score/ScoreDelta.show()
		$CanvasLayer/Score/ScoreDelta.text = ("+" if tick_happiness >0 else "") + "%.2f" % tick_happiness
		$CanvasLayer/Score/Score.text = "%.2f" % current_happiness
		$CanvasLayer/Score/Power.text = str(current_power)
		$CanvasLayer/Score.modulate
		$CanvasLayer/Score/Tween.interpolate_property($CanvasLayer/Score/ScoreDelta, "rect_position", Vector2(868,28), Vector2(868,0), update_interval, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$CanvasLayer/Score/Tween.interpolate_property($CanvasLayer/Score/ScoreDelta, "modulate", Color(1,1,1,1), Color(1,1,1,0), update_interval, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$CanvasLayer/Score/Tween.start()


# Called when the node enters the scene tree for the first time.
func _ready():
	$Switch/Area2D.connect("input_event", self, "click_switch")
	
	var idx = 0
	for item in $Lights.get_children():
		var hotspot: Hotspot = item.get_node("Hotspot")
		if hotspot:
			hotspot.uid = idx
			idx += 1
			hotspot.connect("input_event", self, "click_hotspot", [hotspot])

	$CanvasLayer/Score/ScoreDelta.hide()
	$Girl.hide()
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
	$CanvasLayer/Intro1.show()
	
	$CanvasLayer/AudioStreamPlayer.stream = music_on
	$CanvasLayer/AudioStreamPlayer.volume_db = linear2db(music_volume)
	$CanvasLayer/AudioStreamPlayer.play()

	
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
	if current_intro <= 4:
		$CanvasLayer.get_node("Intro" + str(current_intro)).show()
	else:
		current_state = 'playing'
		call_deferred("girl_move")
		scoring_paused = false

func click_hotspot(camera, event: InputEvent, position, hotspot: Hotspot):
	if event.is_pressed():
		if not scoring_paused:
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
		if current_hotspot != -1:
			#get_tree().set_input_as_handled()
			current_hotspot = -1
			$CanvasLayer/ControlPopup.hide()
		


func click_switch(camera, event: InputEvent, position):
	if event.is_pressed():
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

func _process(delta):
	update_statuses(delta)
	# move to cursor
	if current_state=="playing":
		var vec = get_viewport().get_mouse_position() - $LittleJelly.global_position
		$LittleJelly.look_at(get_viewport().get_mouse_position())
		$LittleJelly.rotation -= PI/4
		if vec.length() < 100:
			$LittleJelly.rotation = lerp(0, $LittleJelly.rotation, vec.length()/100)
		$LittleJelly.global_position = lerp($LittleJelly.global_position, get_viewport().get_mouse_position(), 0.1)
	
func girl_move():
	$Girl.animation = "walk"
	var move_time = 5
	if girl_at == 0:
		$Girl.flip_h = 0
		$Tween.interpolate_property($Girl, "global_position", girl_left, girl_right, move_time)
		girl_at = 1
	else:
		$Girl.flip_h = 1
		$Tween.interpolate_property($Girl, "global_position", girl_right, girl_left, move_time)
		girl_at = 0
	$Tween.interpolate_deferred_callback(self,  move_time, "girl_stop_sound")
	$Tween.interpolate_deferred_callback(self,  move_time*2, "girl_move")
	$Girl/AudioStreamPlayer.volume_db = 3
	$Girl/AudioStreamPlayer.play()
	$Tween.start()

func girl_stop_sound():
	$Girl/AudioStreamPlayer.stop()
