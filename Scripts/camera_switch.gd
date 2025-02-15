extends Node3D

@onready var libu_camera = $"../Libu/LibuCamera3D"  # Referência à câmera da Libu
@onready var character_switch = $"../Character Switch"  # Referência ao sistema de troca de personagem
@onready var crosshair = $"../CanvasLayer/CrossHair/Mira"  # Referência ao nó da mira
var player_inside: bool = false  # Verifica se o jogador está na área
var current_camera_mode: int = 0  # 0 = Normal, 1 = Side Scroll, 2 = Primeira Pessoa

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):  # Verifica se o corpo pertence ao grupo "Player"
		player_inside = true

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		player_inside = false

func _input(event):
	# Verifica se o jogador está na área e pressionou o botão de interação
	if player_inside and event.is_action_pressed("ui_interact"):
		toggle_camera_mode()

func toggle_camera_mode():
	# Determina o personagem ativo e a câmera correspondente
	var active_camera = null
	if character_switch.current_character == 0:
		active_camera = libu_camera
	else:
		active_camera = character_switch.vanessa_camera  # Pega a referência da câmera da Vanessa

	if active_camera == null:
		print("Erro: Câmera do personagem ativo não encontrada!")
		return

	# Alterna entre os modos de câmera
	current_camera_mode = (current_camera_mode + 1) % 3  # 0, 1, 2
	
	# Aplica o estado para ambas as câmeras
	update_camera_state()

	print("Modo da câmera alternado para:", current_camera_mode)

func update_camera_state():
	# Determina a câmera ativa com base no personagem atual
	var active_camera = null
	if character_switch.current_character == 0:  # Libu
		active_camera = libu_camera
	elif character_switch.current_character == 1:  # Vanessa
		active_camera = character_switch.vanessa_camera

	if active_camera == null:
		print("Erro: Câmera ativa não encontrada!")
		return

	# Atualiza o estado da câmera e controla a visibilidade da mira
	if current_camera_mode == 0:  # Modo Normal (terceira pessoa)
		active_camera.deactivate_side_scroll()
		active_camera.deactivate_first_person()
		crosshair.visible = false  # Desativa a mira
	elif current_camera_mode == 1:  # Modo Side Scroll
		active_camera.activate_side_scroll()
		crosshair.visible = false  # Desativa a mira
	elif current_camera_mode == 2:  # Modo Primeira Pessoa
		active_camera.activate_first_person()
		crosshair.visible = true  # Ativa a mira

	# Emite um sinal para sincronizar o estado com a troca de personagem
	character_switch.sync_camera_state(current_camera_mode)
