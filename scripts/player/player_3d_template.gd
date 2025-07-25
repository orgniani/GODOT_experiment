extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.0

@export_group("Runner Settings")
@export var lane_spacing := 4.0
@export var lane_count := 3
@export var jump_duration := 0.6
@export var jump_height := 2.5

@onready var _skin: SkeletonSkin = %SkeletonSkin
@onready var _landing_sound: AudioStreamPlayer3D = %LandingSound
@onready var _jump_sound: AudioStreamPlayer3D = %JumpSound
@onready var _dust_particles: GPUParticles3D = %DustParticles
@onready var death_sensor = $DeathSensor

var _current_lane := 1
var _target_z := 0.0
var _was_on_floor_last_frame := true
var _death_enabled := false

# Simulated ground state
var _is_on_ground := true
var _jump_timer := 0.0

func _ready() -> void:
	Events.kill_plane_touched.connect(func on_kill_plane_touched():
		_skin.idle()
	)
	Events.flag_reached.connect(func on_flag_reached():
		_skin.idle()
		_dust_particles.emitting = false
	)

	await get_tree().create_timer(1.0).timeout
	_death_enabled = true

func _process(delta):
	if death_sensor.is_colliding():
		death()
		
func _physics_process(delta: float) -> void:
	# === LANE SWITCHING ===
	if Input.is_action_just_pressed("move_left") and _current_lane > 0:
		_current_lane -= 1
	elif Input.is_action_just_pressed("move_right") and _current_lane < lane_count - 1:
		_current_lane += 1

	_target_z = (_current_lane - 1) * lane_spacing
	global_position.z = lerp(global_position.z, _target_z, delta * 10.0)
	
	if not _is_on_ground:
		var t := 1.0 - (_jump_timer / jump_duration)
		var jump_offset := -4.0 * (t - 0.5) * (t - 0.5) + 1.0 
		global_position.y = jump_offset * jump_height
	else:
		global_position.y = 0.0 

	# === SIMULATED JUMPING ===
	if _is_on_ground and Input.is_action_just_pressed("jump"):
		_skin.jump()
		_jump_sound.play()
		_is_on_ground = false
		_jump_timer = jump_duration

	if not _is_on_ground:
		_jump_timer -= delta
		if _jump_timer <= 0.0:
			_is_on_ground = true
			_skin.move()
		else:
			_skin.fall()
	else:
		_skin.move()

	# === PARTICLES + LANDING SOUND ===
	_dust_particles.emitting = _is_on_ground

	if _is_on_ground and not _was_on_floor_last_frame:
		_landing_sound.play()

	_was_on_floor_last_frame = _is_on_ground

func death():
	get_tree().reload_current_scene()
