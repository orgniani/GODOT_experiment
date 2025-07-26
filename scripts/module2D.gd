extends Node2D

@onready var level = $"../"
var speed = 200  # pixels per second

func _physics_process(delta):
	position.x -= speed * delta
	if position.x < -200:  # adjust threshold based on module width
		level.spawn_module(position.x + (level.amnt * level.offset))
		queue_free()
