extends Enemy

@onready var animtree = $AnimationTree
var alertBlend = 0.0
var walkBlend = 0.0
var runBlend = 0.0
var shootBlend = 0.0
var dieBlend = 0.0

var sfxplayer: AudioStreamPlayer3D
@onready var sfx_callingforbackup = preload("res://audio/soldier/soldier_callingforbackup.ogg")
@onready var sfx_engagenow = preload("res://audio/soldier/soldier_engagenow.ogg")
@onready var sfx_fire1 = preload("res://audio/soldier/soldier_fire1.ogg")
@onready var sfx_fire2 = preload("res://audio/soldier/soldier_fire2.ogg")
@onready var sfx_fire3 = preload("res://audio/soldier/soldier_fire3.ogg")
@onready var sfx_go1 = preload("res://audio/soldier/soldier_go1.ogg")
@onready var sfx_go2 = preload("res://audio/soldier/soldier_go2.ogg")
@onready var sfx_grenade1 = preload("res://audio/soldier/soldier_grenade1.ogg")
@onready var sfx_grenade2 = preload("res://audio/soldier/soldier_grenade2.ogg")
@onready var sfx_holdtheperimeter = preload("res://audio/soldier/soldier_holdtheperimeter.ogg")
@onready var sfx_hurt1 = preload("res://audio/soldier/soldier_hurt1.ogg")
@onready var sfx_hurt2 = preload("res://audio/soldier/soldier_hurt2.ogg")
@onready var sfx_hurt3 = preload("res://audio/soldier/soldier_hurt3.ogg")
@onready var sfx_hurt4 = preload("res://audio/soldier/soldier_hurt4.ogg")
@onready var sfx_move = preload("res://audio/soldier/soldier_move.ogg")
@onready var sfx_openfire = preload("res://audio/soldier/soldier_openfire.ogg")
@onready var sfx_prepareforcontact = preload("res://audio/soldier/soldier_prepareforcontact.ogg")
@onready var sfx_reloading1 = preload("res://audio/soldier/soldier_reloading1.ogg")
@onready var sfx_reloading2 = preload("res://audio/soldier/soldier_reloading2.ogg")
@onready var sfx_reloading3 = preload("res://audio/soldier/soldier_reloading3.ogg")
@onready var sfx_requestingreinforcements = preload("res://audio/soldier/soldier_requestingreinforcements.ogg")
@onready var sfx_scanningfortarget = preload("res://audio/soldier/soldier_scanningfortarget.ogg")
@onready var sfx_stayalert = preload("res://audio/soldier/soldier_stayalert.ogg")
@onready var sfx_supressingfire = preload("res://audio/soldier/soldier_supressingfire.ogg")
@onready var sfx_targetspotted = preload("res://audio/soldier/soldier_targetspotted.ogg")

## SFX Generic
@onready var sfx_generic = [
	sfx_stayalert,
	sfx_callingforbackup,
	sfx_engagenow,
	sfx_fire1,
	sfx_fire2,
	sfx_go1,
	sfx_go2,
	sfx_holdtheperimeter,
	sfx_move,
	sfx_openfire,
	sfx_prepareforcontact,
	sfx_requestingreinforcements,
	sfx_scanningfortarget,
	sfx_supressingfire,
	sfx_targetspotted
]

## SFX Reloading
@onready var sfx_reloading = [
	sfx_reloading1,
	sfx_reloading2,
	sfx_reloading3,
]

## SFX Grenade
@onready var sfx_grenade = [
	sfx_grenade1,
	sfx_grenade2
]

## SFX Hurt
@onready var sfx_hurt = [
	sfx_hurt1,
	sfx_hurt2,
	sfx_hurt3,
	sfx_hurt4,
]

@onready var currentSFX = sfx_generic[0]

var ALERT = 10
var RUN = 20

var sfxTimer = 0
var talking = false
@export var maxTimer = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	sfxplayer = AudioStreamPlayer3D.new()
	self.add_child(sfxplayer)
	SetSFX(currentSFX)
	add_to_group("Soldier")
	sfxplayer.connect("finished",finished)
	pass # Replace with function body.

func finished():
	talking = false

func SetSFX(sfx):
	sfxplayer.set_stream(sfx)
	sfxplayer.set_volume_db(1.0)
	sfxplayer.set_max_distance(50)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("Interact"):
		state = ALERT
	
	match(state):
		IDLE:
			pass
		ALERT:
			alertBlend = lerp(alertBlend,1.0,.1)
			animtree.set("parameters/Alert/blend_amount", alertBlend)
			sfxTimer += delta
			var cantalk = true 
			if sfxTimer > maxTimer:
				for i in get_tree().get_nodes_in_group("Soldier"):
					if i.talking: cantalk = false
					pass
				
				if cantalk: PlayRandomSound("generic")
			pass
	pass

func PlayRandomSound(type):
	sfxTimer = 0
	
	var arr = []
	match(type):
		"generic": arr = sfx_generic
		"reloading": arr = sfx_reloading
		"grenade": arr = sfx_grenade
		"hurt": arr = sfx_hurt
	
	var rand_index = randi_range(0,arr.size()-1)
	var rand_sfx = arr[rand_index]
	
	currentSFX = rand_sfx
	SetSFX(currentSFX)
	sfxplayer.play()
	talking = true
	pass

func ResetBlends():
	alertBlend = 0.0
	walkBlend = 0.0
	runBlend = 0.0
	shootBlend = 0.0
	dieBlend = 0.0

func ChangeState(newState):
	ResetBlends()
	state = newState
