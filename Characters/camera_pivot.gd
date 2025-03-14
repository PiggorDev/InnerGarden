extends Node3D

@export var player: CharacterBody3D
@export var sensitivity: float = 0.1
@export var min_pitch: float = -80
@export var max_pitch: float = 80
@export var offset_distance: float = 10.0
@export var height: float = 5.0
@export var zoom_speed: float = 0.5
@export var max_offset_distance: float = 8
@export var min_offset_distance: float = 2
@export var max_height: float = 3.5
@export var min_height: float = 0.5
@onready var mesh_instance = $"../Sprite3D"

var yaw: float = 0
var pitch: float = 0
var camera_pivot: Node3D = null

func _ready():
	# Captura o mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Se `player` não estiver configurado no editor, tenta pegar o pai
	if not player:
		player = get_parent()
		if not player:
			print("❌ Erro: jogador (player) não configurado!")
			return

	# Encontrar o CameraPivot dentro do Player
	camera_pivot = player.get_node_or_null("CameraPivot")
	if camera_pivot:
		print("✅ CameraPivot encontrado:", camera_pivot.name)
	else:
		print("⚠️ Erro: CameraPivot não foi encontrado!")

	# Inicializa os valores de rotação
	yaw = rotation_degrees.y
	pitch = 0  

func _input(event):
	# 🎮 Controle de rotação (Yaw e Pitch)
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, min_pitch, max_pitch)  # Evita que vire de ponta cabeça

		rotation_degrees.y = yaw  # Aplica rotação horizontal

		if camera_pivot:
			camera_pivot.rotation.x = deg_to_rad(pitch)  # Aplica o Pitch corretamente
			print("🎥 Pitch (Cima/Baixo):", camera_pivot.rotation_degrees.x)
		else:
			print("⚠️ Erro: CameraPivot não foi encontrado!")

	# 🔍 Controle de Zoom com a roda do mouse
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		# Ajusta o zoom (distância da câmera)
		var previous_offset = offset_distance  # Armazena a distância anterior para suavizar a transição
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			offset_distance = max(offset_distance - zoom_speed, min_offset_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			offset_distance = min(offset_distance + zoom_speed, max_offset_distance)

		# 📌 Garante que temos referência do Sprite3D da Libu
		if camera_pivot and mesh_instance:
			var direction = (global_transform.origin - mesh_instance.global_transform.origin).normalized()

			# 🔹 Ajusta a posição da câmera movendo-se na direção correta SEM ALTERAR O ÂNGULO BRUSCAMENTE
			var target_position = mesh_instance.global_transform.origin + (direction * offset_distance)

			# 🔹 Ajuste suave da altura para evitar saltos
			var target_height = remap(offset_distance, min_offset_distance, max_offset_distance, mesh_instance.global_transform.origin.y, max_height)
			target_position.y = lerp(global_transform.origin.y, target_height, 0.15)  # Transição suave da altura

			# 🔹 Aplica a posição final suavemente para um zoom fluido sem saltos
			global_transform.origin = global_transform.origin.lerp(target_position, 0.15)

			# 🔹 Ajusta apenas a rotação vertical de forma suave para evitar cortes
			var target_pitch = lerp(rotation_degrees.x, pitch, 0.1)
			rotation_degrees.x = target_pitch  # Mantém a rotação mais estável



func _unhandled_input(event):
	# Recaptura o mouse ao clicar na tela
	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			offset_distance = max(offset_distance - zoom_speed, min_offset_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			offset_distance = min(offset_distance + zoom_speed, max_offset_distance)

	# Aplica o zoom corretamente movendo a câmera em direção ao `CameraPivot`
	if camera_pivot:
		var direction = -camera_pivot.global_transform.basis.z.normalized()
		global_transform.origin = camera_pivot.global_transform.origin + (direction * offset_distance)

		
func _process(delta):
	if camera_pivot and player:
		# Faz o CameraPivot seguir a posição do jogador, inclusive no eixo Y
		camera_pivot.global_transform.origin = player.global_transform.origin
		camera_pivot.global_transform.origin.y += height  # Mantém a altura ajustável

		# Move a câmera para trás do CameraPivot respeitando o deslocamento correto
		var direction = -camera_pivot.global_transform.basis.z.normalized()
		global_transform.origin = camera_pivot.global_transform.origin + (direction * offset_distance)

		# Faz a câmera olhar para o jogador
		look_at(camera_pivot.global_transform.origin, Vector3.UP)
