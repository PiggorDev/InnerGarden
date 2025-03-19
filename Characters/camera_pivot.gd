extends Node3D

@export var sensitivity: float = 0.1

# 🔥 Limites de rotação para **Terceira Pessoa**
@export var min_pitch_tpp: float = -30  # Inclinação mínima no modo terceira pessoa
@export var max_pitch_tpp: float = 50   # Inclinação máxima no modo terceira pessoa

# 🔥 Limites de rotação para **Primeira Pessoa**
@export var min_pitch_fps: float = -89  # Permite olhar totalmente para baixo
@export var max_pitch_fps: float = 89   # Permite olhar totalmente para cima

var yaw: float = 0
var pitch_fps: float = 0  # 🔥 Valor exclusivo do FPS
var pitch_tpp: float = 0  # 🔥 Valor exclusivo do TPS
var is_first_person_active: bool = false  # Estado da câmera

@onready var camera = get_node_or_null("LibuCamera3D")  # Pega a câmera FPS

func _input(event):
	if not camera:
		return  # 🚨 Evita erro caso a câmera não esteja carregada

	# 🚫 Bloqueia rotação no Side Scroll
	if camera.is_side_scroll_active:
		rotation_degrees = Vector3.ZERO
		yaw = 0
		pitch_fps = 0
		pitch_tpp = 0
		set_process(false)
		return

	# 🖱️ **Ajuste da rotação pelo mouse**
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity

		if is_first_person_active:
			# FPS -> Usa apenas os valores do FPS
			pitch_fps -= event.relative.y * sensitivity
			pitch_fps = clamp(pitch_fps, min_pitch_fps, max_pitch_fps)

			# 🔥 Aplica os valores APENAS na câmera FPS
			camera.rotation_degrees.x = pitch_fps
			camera.rotation_degrees.y = yaw
		else:
			# TPS -> Usa apenas os valores do TPS
			pitch_tpp -= event.relative.y * sensitivity
			pitch_tpp = clamp(pitch_tpp, min_pitch_tpp, max_pitch_tpp)

			# 🔥 Aplica os valores APENAS no CameraPivot do TPS
			rotation_degrees.x = pitch_tpp
			rotation_degrees.y = yaw

# 🚀 **Garante que o estado da câmera está correto**
func _on_first_person_toggled(active: bool):  
	is_first_person_active = active  # Atualiza o estado
