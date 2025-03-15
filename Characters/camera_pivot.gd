extends Node3D

@export var sensitivity: float = 0.1
@export var min_pitch: float = -80
@export var max_pitch: float = 80
var yaw: float = 0
var pitch: float = 0

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

		# 🔹 Aplica a rotação horizontal e vertical no próprio pivot
		rotation_degrees.y = rad_to_deg(yaw)  # Rotação horizontal (girar em torno do player)
		rotation_degrees.x = rad_to_deg(pitch)  # Rotação vertical (olhar para cima/baixo)
