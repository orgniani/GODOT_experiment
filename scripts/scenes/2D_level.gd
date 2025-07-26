extends Node2D

@export var modules: Array[PackedScene] = []

@export var background: ParallaxBackground
@export var scroll_speed := Vector2(-50, 0) # pixels per second, X scroll only

var rng = RandomNumberGenerator.new()
var amnt = 30
var offset = 160
var initObs = 0

func _ready():
	for n in amnt:
		spawn_module(n * offset)

func _process(delta):
	background.scroll_offset += scroll_speed * delta

func spawn_module(x_position: float):
	if initObs > 5:
		rng.randomize()
		var num = rng.randi_range(0, modules.size() - 1)
		var instance = modules[num].instantiate()
		instance.position.x = x_position
		add_child(instance)
	else:
		var instance = modules[0].instantiate()
		instance.position.x = x_position
		add_child(instance)
		initObs += 1
