extends Node3D

@export var sensitivity: float = 0.1
@export var min_pitch: float = -80
@export var max_pitch: float = 80

var yaw: float = 0
var pitch: float = 0

func _input(event):
	var camera = get_node_or_null("LibuCamera3D")
	if camera and camera.is_side_scroll_active:
		return  # 🔥 Impede qualquer ajuste no Side Scroll

	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

		# 🔹 Aplica a rotação no pivot
		rotation_degrees.y = rad_to_deg(yaw)
		rotation_degrees.x = rad_to_deg(pitch)
