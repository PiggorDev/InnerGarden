extends Node3D

@onready var character_switch = $"../Character Switch"  # Sistema de troca de personagem
@onready var crosshair = $"../CanvasLayer/CrossHair/Mira"  # Mira da câmera
@onready var libu_camera = get_node_or_null("../Libu/CameraPivot/LibuCamera3D")
var player_inside: bool = false  # Se o jogador está na área
var current_camera_mode: int = 0  # 0 = Normal, 1 = Side Scroll, 2 = Primeira Pessoa

func _ready():
	if libu_camera == null:
		print("🚨 Erro: Não encontrou a câmera da Libu! Verifique o caminho.")
	else:
		print("✅ Libu Camera encontrada:", libu_camera)
		
func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		player_inside = true

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		player_inside = false

func _input(event):
	if player_inside and event.is_action_pressed("ui_interact"):
		toggle_camera_mode()

func toggle_camera_mode():
	# Verifica qual personagem está ativo e qual câmera deve ser usada
	var active_camera = get_active_camera()

	# Debug para ver se a câmera está correta
	print("📸 Libu Camera:", libu_camera)
	print("📸 Vanessa Camera:", character_switch.vanessa_camera)
	print("🎮 Personagem Atual:", character_switch.current_character)

	if active_camera == null:
		print("⚠️ Erro: Câmera do personagem ativo não encontrada!")
		return

	# Alterna entre os modos de câmera (Normal → Side Scroll → Primeira Pessoa)
	current_camera_mode = (current_camera_mode + 1) % 3  
	update_camera_state()

	print("🎥 Modo da câmera alterado para:", current_camera_mode)

func update_camera_state():
	var active_camera = get_active_camera()
	if active_camera == null:
		print("⚠️ Erro: Nenhuma câmera ativa encontrada!")
		return

	# **Configura o modo da câmera com base no estado atual**
	if current_camera_mode == 0:  # Modo Normal (Terceira Pessoa)
		active_camera.call("deactivate_side_scroll")
		active_camera.call("deactivate_first_person")
		crosshair.visible = false  # Esconde a mira
	elif current_camera_mode == 1:  # Modo Side Scroll
		active_camera.call("activate_side_scroll")
		crosshair.visible = false  # Esconde a mira
	elif current_camera_mode == 2:  # Modo Primeira Pessoa
		active_camera.call("activate_first_person")  # Agora chamando corretamente
		crosshair.visible = true  # Ativa a mira

	# Sincroniza o estado com o sistema de troca de personagem
	character_switch.sync_camera_state(current_camera_mode)

func get_active_camera():
	# Retorna a câmera do personagem ativo
	if character_switch.current_character == 0:  # Se for a Libu
		return libu_camera
	elif character_switch.current_character == 1:  # Se for a Vanessa
		return character_switch.vanessa_camera  # Certifique-se de que `vanessa_camera` está correto
	return null
