extends Node3D

@export var rotation_speed: float = 90.0  # Velocidade de rotação (graus/segundo)
var is_open: bool = false  # Estado da porta
var target_angle: float = 0.0  # Ângulo alvo
var player_in_range: bool = false  # Jogador próximo?

func _process(delta):
	# Faz a porta girar gradualmente até o ângulo alvo
	var current_angle = rotation_degrees.y
	if abs(current_angle - target_angle) > 0.1:
		var direction = sign(target_angle - current_angle)
		rotation_degrees.y += direction * rotation_speed * delta
		if abs(rotation_degrees.y - target_angle) < rotation_speed * delta:
			rotation_degrees.y = target_angle

func toggle_door():
	# Verifica se o jogador está próximo antes de abrir/fechar a porta
	if player_in_range:
		if is_open:
			target_angle = 0.0  # Porta fechada
		else:
			target_angle = 90.0  # Porta aberta
		is_open = not is_open

func _on_Area_3d_body_entered(body):
	# Detecta se o jogador entrou na área
	if body.is_in_group("Player"):  # Verifique se o jogador pertence ao grupo "Player"
		player_in_range = true

func _on_Area3D_body_exited(body):
	# Detecta se o jogador saiu da área
	if body.is_in_group("Player"):
		player_in_range = false
