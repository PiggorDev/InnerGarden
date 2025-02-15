extends Node3D

@export var move_speed: float = 2.0
@export var move_distance: float = 5.0

var velocity: Vector3 = Vector3.ZERO
var _direction: Vector3 = Vector3(1, 0, 0)
var _start_position: Vector3
var _time: float = 0.0
var previous_position: Vector3

@onready var static_body = $"block-moving/block-moving_col"
@onready var area = $Area3D

func _ready():
	_start_position = global_transform.origin
	previous_position = _start_position  # importante inicializar aqui

	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta):
	_time += delta
	var offset = sin(_time * move_speed) * move_distance
	var new_position = _start_position + _direction * offset

	velocity = (new_position - previous_position) / delta

	global_transform.origin = new_position
	static_body.global_transform.origin = new_position

	previous_position = new_position

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.call_deferred("_on_platform_entered", self)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.call_deferred("_on_platform_exited", self)
