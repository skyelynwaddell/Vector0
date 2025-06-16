extends CanvasLayer

@onready var stats_label = $stats
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var camera = get_viewport().get_camera_3d()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	# --- Helper ---
func round_decimal(value: float, decimals: int) -> float:
	var factor = pow(10, decimals)
	return round(value * factor) / factor
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("F3"):
		if not visible: 
			print("open stats")
			show()
		else: hide()
	
	if not visible: return
	
	var stats = []

	# --- FPS ---
	stats.append("=== Game Stats ===")
	stats.append("Engine Version: " + str(Engine.get_version_info().string))
	stats.append("FPS: " + str(Engine.get_frames_per_second()))
	stats.append("Max FPS: " + str(Engine.max_fps))
	stats.append("Frame Time: " + str(round_decimal(1000.0 / Engine.get_frames_per_second(), 2)) + " ms")

	# --- Memory ---
	stats.append("\n=== Memory ===")
	stats.append("Static Mem: " + str(round_decimal(OS.get_static_memory_usage() / 1_000_000.0, 2)) + " MB")
	stats.append("Max Static Mem: " + str(round_decimal(OS.get_static_memory_peak_usage() / 1_000_000.0, 2)) + " MB")
	#stats.append("Video Mem: " + str(round_decimal(OS.get_video_memory_usage() / 1_000_000.0, 2)) + " MB")
	
	# --- Physics ---
	stats.append("\n=== Physics ===")
	stats.append("Physics Ticks Per Second: " + str(Engine.physics_ticks_per_second))
	stats.append("Max Physics Steps Per Frame : " + str(Engine.max_physics_steps_per_frame))

	# --- Scene Info ---
	#stats.append("\n=== Scene ===")
	#stats.append("Node Count: " + str(Engine.get_total_nodes_count()))
	#stats.append("Object Count: " + str(Object.get_instance_count()))

	# --- Rendering ---
	stats.append("\n=== Rendering ===")
	stats.append("Draw Calls: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
	#stats.append("Render Time: " + str(round_decimal(Performance.get_monitor(Performance.TIME_RENDER_FRAME), 3)) + " ms")
	#stats.append("Physics Time: " + str(round_decimal(Performance.get_monitor(Performance.TIME_PHYSICS_FRAME), 3)) + " ms")

	# --- Player Info ---
	if is_instance_valid(player):
		stats.append("\n=== Player ===")
		stats.append("Position: " + str(player.global_position))
		stats.append("Rotation: " + str(player.global_rotation_degrees))

	# --- Camera Info ---
	if is_instance_valid(camera):
		stats.append("\n=== Camera ===")
		stats.append("Position: " + str(camera.global_position))
		stats.append("FOV: " + str(round_decimal(camera.fov, 2)))

	stats_label.text = "\n".join(stats)
	
	pass
