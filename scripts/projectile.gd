extends CharacterBody3D

@export var current_projectile_type := Defs.PROJECTILE_TYPE.ELECTRIC_BALL
@export var power : int = 20
@export var speed: float = 15.0
@export var spin_speed : float = 10.0
@export var destroy_distance: float = 1000.0
@export var direction: Vector3 = Vector3.ZERO
var start_position: Vector3

func _ready() -> void:
	start_position = global_position
	
	## Hide all the projectile models
	%ElectricBall.hide()
	%Slime.hide()
	%Bullet.hide()
	%ShotgunBullet.hide()
	
	## Show the correct projectile model
	match(current_projectile_type):
		Defs.PROJECTILE_TYPE.ELECTRIC_BALL: %ElectricBall.show()
		Defs.PROJECTILE_TYPE.SLIME: %Slime.show()
		Defs.PROJECTILE_TYPE.BULLET: %Bullet.show()
		Defs.PROJECTILE_TYPE.SHOTGUN_BULLET: %ShotgunBullet.show()
		
func _physics_process(delta: float) -> void:	
	self.velocity.x = direction.x * speed
	self.velocity.z = direction.z * speed
	self.velocity.y = direction.y * speed
	
	match(current_projectile_type):
		Defs.PROJECTILE_TYPE.SLIME: Rotate(delta)
		Defs.PROJECTILE_TYPE.BULLET, Defs.PROJECTILE_TYPE.SHOTGUN_BULLET:
			look_in_direction(Vector3(direction.x, 0, direction.z))  # horizontal only
	
	
	move_and_slide()

	if global_position.distance_to(start_position) > destroy_distance:
		queue_free()
		
func Rotate(delta): if spin_speed != 0.0: rotate_object_local(Vector3.FORWARD, delta * spin_speed)
		

func _on_entered(body: Node3D) -> void:	
	#return
	## check if the projectile hit a wall
	if body == null: return
		
	var parent = body.get_parent()
	if parent != null:
		if parent.is_in_group("Enemy") == false:
			if parent.has_method("Hurt"): parent.Hurt(power)
			
	if body.collision_layer & (1 << 0): queue_free() # Layer 1 = bit 0
	
func look_in_direction(dir: Vector3) -> void:
	if dir.length() == 0:
		return
	look_at(global_position + dir, Vector3.UP)
