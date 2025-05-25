@tool
extends OmniLight3D

@export var brightness = 2.0
@export var flicker_timer := 1.0
@export var is_on := 0
@export var style = LIGHT_STYLE.NORMAL
@export var color := Color(1.0,1.0,1.0)

var current_flicker_time := 0
var is_flashing := true ## so we know what state of the flash it is in

enum LIGHT_STYLE {
	NORMAL=0,
	SLOW_STRONG_PULSE=1,
	PULSE_NO_BLACK=2,
	GENTLE_PULSE=3,
	FLICKER_A=4,
	FLICKER_B=5,
	FAST_STROBE=6,
	SLOW_STROBE=7
}

func _func_godot_apply_properties(props:Dictionary):
	if "is_on" in props: is_on = props.is_on as int
	if "brightness" in props: brightness = props.brightness as float
	if "style" in props: style = props.style as LIGHT_STYLE
	if "color" in props: 
		
		## Trenchbroom stores the color as a string so i have to get it and turn it into seperate variables
		var str_color = props.color
		var rgb_values = str_color.split(" ")

		## need to convert each rgb 0-255 color to a 0-1 format
		var r = int(rgb_values[0]) / 255.0
		var g = int(rgb_values[1]) / 255.0
		var b = int(rgb_values[2]) / 255.0

		## make and set the color
		color = Color(r, g, b)
		light_color = color
	
	## Depending on if the light was on or not change the brightness
	if is_on == 0: light_energy = 0.0
	else: light_energy = brightness
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## you can override the trenchbroom settings with the settings in godot
	light_energy = brightness
	light_color = color
	if is_on == 0: light_energy = 0.0
	pass # Replace with function body.


## this function causes the light to flicker/pulse in different ways
func Pulse(min_light, max_light, _flicker_timer, delta):
	if is_flashing:
		light_energy -= _flicker_timer * delta
		
		if light_energy <= min_light: 
			is_flashing = false
		
	else:
		light_energy += _flicker_timer * delta
		
		if light_energy >= max_light: 
			is_flashing = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if is_on == 0: return
	
	match(style):
		## The default light style
		LIGHT_STYLE.NORMAL:
			## Basically we arent going to do nothing here
			## so yeah
			pass
			
		## When you want the light to pulse, but never go completely dark
		LIGHT_STYLE.PULSE_NO_BLACK:
			Pulse(0.5, 2.0, 1.0, delta)
			pass
			
		## When you want the a pulse effect, useful for Siren or Alarm lights
		LIGHT_STYLE.SLOW_STRONG_PULSE:
			## here lets lerp the energy 
			Pulse(0.0, 2.0, 1.0, delta)
			pass
		
		## This pulse is barely noticable, can give some ambience variation without too much attention
		LIGHT_STYLE.GENTLE_PULSE:
			Pulse(0.5, 1.0, 0.2, delta)
			pass
		
		## This --tries-- to similuate if the light was burning out, and as a result flickering
		LIGHT_STYLE.FLICKER_A:
			var _flicker_time = randf_range(0.5, 10.0)
			var _max_light = randf_range(0.1,2.0)
			Pulse(0.8, _max_light, _flicker_time, delta)
			pass
			
		## Another type of flicker, incase multiple lights flicker it wont look stupid and in unison
		LIGHT_STYLE.FLICKER_B:
			var _flicker_time = randf_range(0.6, 10.0)
			var _max_light = randf_range(0.1,2.0)
			Pulse(0.4, _max_light, _flicker_time, delta)
			pass
			
		## I guess you could make a party or something
		LIGHT_STYLE.FAST_STROBE:
			Pulse(0.0, 1.0, 1.0, delta)
			pass
		
		## a slower one idek
		LIGHT_STYLE.SLOW_STROBE:
			Pulse(0.0, 1.0, 0.2, delta)
			pass
	
	pass

## A light is turned on / off when it is triggered.
func on_trigger():
	is_on = !is_on
	if is_on == 0: light_energy = 0.0
	else: light_energy = brightness
