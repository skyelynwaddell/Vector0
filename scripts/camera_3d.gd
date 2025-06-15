extends Camera3D
class_name Camera_ViewModel

var shake_timer := 0.0
var shake_intensity := 0.1
var shake_decay := 1.5
var original_transform : Transform3D
var original_rotation
var in_screenshake := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_transform = transform
	original_rotation = rotation
	Signals.ScreenShake.connect(ScreenShake)


func ScreenShake(duration:float=0.2,_intensity:float=0.1, _decay:float=1.5):
	
	if not in_screenshake:
		original_rotation = rotation
		original_transform = transform
	
	shake_timer = duration
	shake_intensity = _intensity
	shake_decay = _decay
	
	in_screenshake = true


func ScreenShakeHandler(delta):
	if shake_timer <= 0 and in_screenshake == true: 
		in_screenshake = false
		#rotation = original_rotation
		transform.origin = original_transform.origin
		return
		
	if shake_timer <= 0: return ## do this or you will be very dizzy
	
	shake_timer -= delta * shake_decay
	var offset = Vector3(
		randf_range(-1,1),
		randf_range(-1,1),
		randf_range(-1,1)
	) * shake_intensity * shake_timer
	
	var rot = Vector3(
		randf_range(-1,1),
		randf_range(-1,1),
		randf_range(-1,1),
	) * shake_intensity * shake_timer
	
	transform.origin = original_transform.origin + offset
	#rotation = original_transform.basis.get_euler() + rot


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ScreenShakeHandler(delta)
