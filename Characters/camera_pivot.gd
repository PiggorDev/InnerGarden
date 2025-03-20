extends Node3D

@export var sensitivity: float = 0.1

# 🔥 Limites de rotação para **Terceira Pessoa**
@export var min_pitch_tpp: float = -30  
@export var max_pitch_tpp: float = 50  

# 🔥 Limites de rotação para **Primeira Pessoa**
@export var min_pitch_fps: float = -89  
@export var max_pitch_fps: float = 89  

# 🌀 **Variáveis separadas para FPS e TPS**
var yaw_tpp: float = 0
var pitch_tpp: float = 0

var yaw_fps: float = 0
var pitch_fps: float = 0

var is_first_person_active: bool = false  

# 📡 **Novo Sinal para detectar mudança de câmera**
signal first_person_toggled(active: bool)

func _ready():
	# 🚀 **Conectando a câmera para detectar mudanças de modo FPS/TPS**
	var camera = get_node_or_null("LibuCamera3D")
	if camera:
		camera.first_person_toggled.connect(_on_first_person_toggled)

func _input(event):
	var camera = get_node_or_null("LibuCamera3D")

	# 🚫 Bloqueia rotação no Side Scroll
	if camera and camera.is_side_scroll_active:
		rotation_degrees = Vector3.ZERO
		yaw_tpp = 0
		pitch_tpp = 0
		set_process(false)
		return

	# 🖱️ **Movimentação do Mouse**
	if event is InputEventMouseMotion:
		if is_first_person_active and camera:
			# 🚀 **FPS → Usa variáveis separadas**
			yaw_fps -= event.relative.x * sensitivity
			pitch_fps -= event.relative.y * sensitivity

			# 🔥 Garante que FPS está independente
			pitch_fps = clampf(pitch_fps, min_pitch_fps, max_pitch_fps)
			yaw_fps = fmod(yaw_fps, 360)  

			camera.rotation_degrees.y = yaw_fps
			camera.rotation_degrees.x = pitch_fps  

		else:
			# 🎮 **TPS → Usa variáveis separadas**
			yaw_tpp -= event.relative.x * sensitivity
			pitch_tpp -= event.relative.y * sensitivity

			# 🔥 Garante que TPS está independente
			pitch_tpp = clampf(pitch_tpp, min_pitch_tpp, max_pitch_tpp)

			rotation_degrees.y = yaw_tpp
			rotation_degrees.x = pitch_tpp  

func _on_first_person_toggled(active: bool):  
	is_first_person_active = active  

	# 🛠 **Reseta a rotação ao trocar de modo**
	if active:
		print("🎥 Mudando para FPS - Reiniciando Pitch")
		pitch_fps = 0  # FPS começa reto
	else:
		print("🎥 Mudando para TPS - Mantendo limites do Pitch")
		pitch_tpp = clampf(pitch_tpp, min_pitch_tpp, max_pitch_tpp)  # TPS mantém os limites
