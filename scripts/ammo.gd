@tool
extends PickUp
class_name Ammo

@export_group("Ammo Properties")
## Ammo Amount this Pickup provides
@export var AmmoAmount : int = 100
## Select only one option (dont select NULL option!)
@export_enum(
	"9mm", 
	"Carbine",	
	"Shotgun",	 
	"357",
) var ammoType : int = 1

var shouldDestroy = false

@export var difficulty_spawn = 0

func _ready():
	Game.DestroyOnDifficultyFlag(difficulty_spawn, self)
	add_to_group("Entity", true)
	Game.UpdateEntity(self,0)

func _func_godot_apply_properties(props:Dictionary):
	if "amount" in props: AmmoAmount = props.amount as int
	if "difficulty_spawn" in props: difficulty_spawn = props.difficulty_spawn as int
	pass

func _on_body_entered(body):
	if spawn_wait == true: return
	
	if body == null: return
	
	# Check if player collided with Ammo
	if body.is_in_group("Player"):
		
		self.visible = false
		Game.UpdateEntity(self,1)
		print_debug("Picking up ammo!!")
		shouldDestroy = true

		
		var isMelee : bool = false
		var ammoPoolType = null
		
		match(ammoType):
			0: ammoPoolType = "9mm"		# 9mm Bullets
			1: ammoPoolType = "carbine" # Carbine Bullets
			2: ammoPoolType = "shotgun" # Shotgun Shells
			3: ammoPoolType = "357" 	# 357 Bullets
		
		# Make sure we're not giving melee weapons ammo
		if ammoPoolType == null: 
			print_debug("Invalid ammo type for pickup!")
			return
		
		#Get our current weapon equipped
		var weapon = Game.weapons[Game.currentWeapon]
		
		# Find our weapon index, and if the current weapon is a melee weapon
		for i in Game.weaponList:
			if i.index == weapon.index:
				isMelee = i.melee
				pass
		
		# Check if we have max ammo already
		for i in Game.ammoPool:
			if i.type == ammoPoolType:
				print_debug("found type")
				var maxAmmo = 999
				if i.ammo >= maxAmmo: 
					print_debug("Max ammo already reached.")
					return
				
				# Increase ammo amount by pickup amount, and clamp ammo to max ammo
				i.ammo += AmmoAmount
				i.ammo = clamp(i.ammo,0,maxAmmo)
				print_debug(i.ammo)
				MusicPlayer.Sound(MusicPlayer.SFX.PICKUP, MusicPlayer.AUDIO_CHANNEL.SFX, 0.2);
				
				pass
		
		# Update HUD & Remove self from scene
		Console.print_line("Picked up x" + str(AmmoAmount) + " " + str(ammoPoolType) + " ammo.")
		if isMelee == false: body.UpdateHUDSignal.emit()
		#queue_free()
		pass

func _process(delta):
	if Engine.is_editor_hint() : return
	SpawnWait(delta)
	if shouldDestroy: queue_free()
	pass
