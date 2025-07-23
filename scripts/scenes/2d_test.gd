extends Node2D

@export var scroll_speed := 200.0

@onready var _camera := $Camera2D

func _process(delta):
	_camera.position.x += scroll_speed * delta
