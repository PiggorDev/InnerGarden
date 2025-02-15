extends Node3D

@export var player: CharacterBody3D
@export var sensitivity: float = 0.1  # Sensibilidade do mouse
@export var min_pitch: float = -30  # Ângulo mínimo para olhar para baixo
@export var max_pitch: float = 45   # Ângulo máximo para olhar para cima

var yaw: float = 0  # Rotação horizontal (ao redor do jogador)
var pitch: float = 0  # Rotação vertical (cima/baixo)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Esconde o cursor e captura o mouse

	# Inicializa os ângulos baseados na rotação atual do editor
	yaw = rotation_degrees.y
	pitch = $Camera3D.rotation_degrees.x

func _input(event):
	if event is InputEventMouseMotion:
		# Calcula o movimento do mouse
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity

		# Limita o ângulo vertical (pitch)
		pitch = clamp(pitch, min_pitch, max_pitch)

		# Aplica as rotações ao pivô e à câmera
		rotation_degrees.y = yaw
		$Camera3D.rotation_degrees.x = pitch

func _process(delta):
	if player:
		# Move o pivô para acompanhar o jogador
		global_transform.origin = player.global_transform.origin
