extends Node

signal UpdateHUD

## other = the creator instance of the projectile
## target = the initial direction of the projectile
signal SpawnProjectile(other:CharacterBody3D, direction:Vector3) 
