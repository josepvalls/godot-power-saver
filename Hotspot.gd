extends Area2D
class_name Hotspot

var uid = -1

var flicker_delay = 0.01
var flicker_delay_current = 0.0

export var is_speaker = false

export var is_on = true
export var want_to_use = true


export var uses_battery = true
export var battery_level = 0.75
export var is_plugged = true

export var is_powered = true

export var status_str_1 = ""
export var status_str_2 = ""

export var charge_rate = 0.06
export var discharge_rate = 0.04

export var want_to_use_time = 5.0
export var in_stand_by_time = 5.0
export var elapsed = 0.0
export var idle_percent = 0
export var is_in_stand_by = false

export var power_use = 75
export var happiness_generation = 1.0
export var current_happiness = 1.0


func refresh_status(delta):
	if want_to_use_time >=0:
		elapsed += delta
		if elapsed > want_to_use_time+in_stand_by_time:
			want_to_use = false
			is_in_stand_by = false
			idle_percent = 0
		else:
			want_to_use = true
			if elapsed <= want_to_use_time:
				is_in_stand_by = false
				idle_percent = 100.0 * elapsed / want_to_use_time 
			elif elapsed <= want_to_use_time + in_stand_by_time:
				is_in_stand_by = true
				idle_percent = 100.0 * (elapsed-want_to_use_time) / in_stand_by_time 
		idle_percent = 100 - idle_percent
	
	if want_to_use:
		if is_powered and is_on:
			if not is_in_stand_by:
				status_str_1 = "In use"
			else:
				status_str_1 = "In stand-by"
			current_happiness = happiness_generation * delta
		else:
			status_str_1 = "Couldn't use"
			current_happiness = -0.5*happiness_generation * delta
	else:
		if is_on:
			status_str_1 = "Wasting power"
			current_happiness = -0.1
		else:
			status_str_1 = "Off"
			current_happiness = 0
	
	if not uses_battery:
		status_str_2 = "N/A"
		is_powered = true
	else:
		if is_on:
			battery_level -= discharge_rate * delta
			if is_plugged:
				is_powered = true
				battery_level += charge_rate * delta
				if battery_level < .95:
					status_str_2 = "Charging battery"
					is_powered = true
				else:
					status_str_2 = "Powered"
					is_powered = true
			else:
				if battery_level < .05:
					status_str_2 = "Empty battery"
					is_powered = false
					is_on = false
				else:
					status_str_2 = "Using battery"
		else:
			if is_plugged:
				battery_level += charge_rate * delta
				if battery_level < .05:
					status_str_2 = "Empty battery"
					is_powered = false
					is_on = false
				elif battery_level < .95:
					status_str_2 = "Charging battery"
					is_powered = true
				else:
					status_str_2 = "Full battery"
					is_powered = true
	battery_level = clamp(battery_level, 0.0, 1.0)


func _ready():
	if is_on and is_powered:
		get_parent().energy = 1
	else:
		get_parent().energy = 0
		

func do_toggle():
	if is_on:
		is_on = false
		get_parent().energy = 0
	else:
		is_on = true
		get_parent().energy = 1
		
func _process(delta):		
	if is_on:
		# flicker
		flicker_delay_current += delta
		if flicker_delay_current >= flicker_delay:
			flicker_delay_current = 0
			get_parent().energy = 0.7+randf()/4
