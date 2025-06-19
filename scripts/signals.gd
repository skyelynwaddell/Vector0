extends Node

signal UpdateHUD

## other = the creator instance of the projectile
### target = the initial direction of the projectile
#@export var power : int = 20
#@export var speed: float = 15.0
#@export var spin_speed : float = 10.0
#@export var destroy_distance: float = 1000.0
signal SpawnProjectile(
	other:CharacterBody3D, 
	direction:Vector3, 
	style:Defs.PROJECTILE_TYPE,
	power:int,
	speed:float,
	spin_speed:float,
	destroy_distance:float
) 

signal ScreenShake(duration:float,_intensity:float, _decay:float)

signal CrusherZone_PlayerEntered(crusherzone_targetname:String)
signal CrusherZone_PlayerExited(crusherzone_targetname:String)
signal CrusherZone_CrusherEntered(crusherzone_targetname:String)
signal CrusherZone_CrusherExited(crusherzone_targetname:String)
signal EmissionSet(value:int)
signal UpdateEnemyStats
signal DoorUpdateEntity
signal HUDHide
signal HUDShow
signal HUDHidden
signal MainMenuShown
signal MainMenuHidden
signal MapGenerated
signal UpdateWorldMapFile
signal MapGenerating
signal HitmarkerDisplay
