extends Node2D

@export var modules: Array[PackedScene] = []
@export var background: ParallaxBackground
@export var scroll_speed := Vector2(-50, 0)

var rng = RandomNumberGenerator.new()
var amnt := 30
var offset := 160
var initObs := 0

var _last_spawn_x := -INF

func _ready():
	for n in amnt:
		spawn_module(n * offset)

func _process(delta):
	background.scroll_offset += scroll_speed * delta

func spawn_module(x_position: float):
	if abs(x_position - _last_spawn_x) < offset * 0.5:
		return

	_last_spawn_x = x_position

	if initObs <= 5:
		var instance = modules[0].instantiate()
		instance.position = Vector2(x_position, 0)
		add_child(instance)
		initObs += 1
		return

	rng.randomize()
	var num = rng.randi_range(0, modules.size() - 1)
	var instance = modules[num].instantiate()
	instance.position = Vector2(x_position, 0)
	add_child(instance)
