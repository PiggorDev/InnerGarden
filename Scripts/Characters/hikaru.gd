extends Node3D

@export var dialog_texts: Array = ["Olá! Eu sou o Hikaru. :)", "Vou te dar um guarda-chuva."]
var current_dialog_index: int = 0
var is_nearby: bool = false
var player_node: CharacterBody3D = null
var dialog_active: bool = false

# Referências diretas aos nós
@onready var canvas_layer = $"../CanvasLayer"
@onready var dialog_label = $"../CanvasLayer/Dialog/DialogBackground/DialogLabel"
@onready var dialog_background = $"../CanvasLayer/Dialog/DialogBackground"

func _ready():
	# Aguarda um curto tempo para evitar erro de referência
	await get_tree().process_frame
	player_node = get_tree().get_first_node_in_group("Player")  # Busca o jogador pelo grupo "Player"

	Global.has_umbrella = false  # Garante reset
	print("🔄 Inventário e Hotbar resetados com sucesso.")

func _process(_delta):
	# Ativa o diálogo se o jogador estiver perto e pressionar o botão de interação
	if is_nearby and Input.is_action_just_pressed("ui_interact"):
		if dialog_active:
			next_dialog()
		else:
			show_dialog()

func _on_Area3D_body_entered(body):
	if body.is_in_group("Player"):
		is_nearby = true

func _on_Area3D_body_exited(body):
	if body.is_in_group("Player"):
		is_nearby = false
		if dialog_active:
			hide_dialog()

func show_dialog():
	if dialog_label and dialog_background:
		# Exibe a primeira fala do diálogo
		current_dialog_index = 0
		dialog_label.text = dialog_texts[current_dialog_index]
		dialog_label.visible = true
		dialog_background.visible = true
		dialog_active = true

		# Trava o movimento do jogador (se houver suporte no script do jogador)
		if player_node and player_node.has_method("set_dialog_active"):
			player_node.set_dialog_active(true)
	else:
		print("⚠️ DialogLabel ou DialogBackground não encontrado! Verifique o caminho.")

func next_dialog():
	# Avança para a próxima fala ou encerra o diálogo
	current_dialog_index += 1
	if current_dialog_index < dialog_texts.size():
		dialog_label.text = dialog_texts[current_dialog_index]
	else:
		hide_dialog()
		give_item_to_player()  # Dá o item após o diálogo

func hide_dialog():
	if dialog_label and dialog_background:
		dialog_label.visible = false
		dialog_background.visible = false
		dialog_active = false
		
		# Libera o movimento do jogador (se houver suporte no script do jogador)
		if player_node and player_node.has_method("set_dialog_active"):
			player_node.set_dialog_active(false)

func give_item_to_player():
	if Global.has_umbrella:
		print("⚠️ O jogador já possui o guarda-chuva!")
		return

	# Busca o script do inventário no CanvasLayer
	var inventory = get_tree().get_root().find_child("CanvasLayer", true, false)
	if inventory and inventory.has_method("add_item_to_slot"):
		var umbrella_texture = preload("res://Sprites/Inventory/UmbrellaBIG.png")  # Substitua pelo caminho correto
		var success = inventory.add_item_to_slot(umbrella_texture)

		if success:
			Global.has_umbrella = true
			print("✅ Guarda-chuva adicionado ao inventário com sucesso!")
		else:
			print("⚠️ Inventário cheio. Guarda-chuva não adicionado.")
	else:
		print("⚠️ Inventário não encontrado ou método ausente!")
		print("Inventário atualizado com guarda-chuva")
