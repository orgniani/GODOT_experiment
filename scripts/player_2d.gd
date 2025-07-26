extends CharacterBody2D

@export_group("Runner Settings")
@export var jump_force := -500.0
@export var gravity := 1200.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _landing_sound: AudioStreamPlayer2D = $LandingSound
@onready var _jump_sound: AudioStreamPlayer2D = $JumpSound

var _death_enabled := false
var _was_on_floor_last_frame := true
var _is_dead := false

func _ready():
	global_position.x = 150

	Events.kill_plane_touched.connect(func on_kill_plane_touched():
		_sprite.play("idle")
	)
	Events.flag_reached.connect(func on_flag_reached():
		_sprite.play("idle")
	)

	await get_tree().create_timer(1.0).timeout
	_death_enabled = true

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		_jump_sound.play()
		_sprite.play("jump")
		velocity.y = jump_force

	if not is_on_floor():
		_sprite.play("jump")
	else:
		_sprite.play("run")

	if is_on_floor() and not _was_on_floor_last_frame:
		_landing_sound.play()

	_was_on_floor_last_frame = is_on_floor()

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("obstacle") and _death_enabled:
			death()

func death():
	if _is_dead:
		return
	_is_dead = true
	get_tree().reload_current_scene()
