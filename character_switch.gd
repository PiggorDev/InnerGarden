extends Node3D

@export var float_speed: float = 1.5   # Velocidade da flutuação
@export var float_height: float = 0.2   # Altura máxima da flutuação

var base_position: Vector3              # Posição base para o efeito de flutuação
var time_passed: float = 0.0            # Tempo acumulado

@onready var libu = $"../Libu"
@onready var hud_libu = $"../CanvasLayer"
@onready var hud_vanessa = $"../CanvasLayer"
@onready var libu_camera = $"../Libu/LibuCamera3D"  # Caminho para a câmera da Libu



var vanessa_scene = preload("res://Characters/Vanessa.tscn")
var vanessa_camera: Camera3D = null  # Variável para armazenar a câmera da Vanessaa
var vanessa_instance = null           # Armazena a instância da Vanessa

var player_inside: bool = false       # Indica se o jogador está na área
var current_character: int = 0        # 0 = Libu, 1 = Vanessa

var camera_node: Node = null

var libu_health: int = 2  # Vida inicial da Libu
var vanessa_health: int = 4  # Vida inicial da Vanessa


func _ready():
	base_position = global_transform.origin


	if libu:
		libu_health = libu.current_health
		libu.update_life_bar()

	if vanessa_instance:
		vanessa_health = vanessa_instance.current_health
		vanessa_instance.update_life_bar()

	# Exibir a Libu e configurar sua HUD
	if libu:
		libu.show()
		if libu.has_method("update_life_bar"):
			libu.update_life_bar()  # Atualiza a barra de vida da Libu ao iniciar o jogo
		else:
			print("Método 'update_life_bar' não encontrado na Libu.")
		
		if libu.has_node("LibuCamera3D"):
			camera_node = libu.get_node("LibuCamera3D")
			camera_node.make_current()  # Configura a câmera inicial
		else:
			print("LibuCamera3D não encontrada em Libu!")
	else:
		print("Nó Libu não encontrado!")

	# Certificar que as barras de vida da Vanessa estão escondidas no início
	var hud_canvas = $"../CanvasLayer"
	if hud_canvas:
		var vanessa_nodes = [
			"HUD_Life_Full_Vanessa",
			"HUD_Life_Hurt_Vanessa",
			"HUD_Life_Hurt2_Vanessa",
			"HUD_Life_Hurt3_Vanessa",
			"HUD_Life_Dead_Vanessa"
		]
		for node_name in vanessa_nodes:
			if hud_canvas.has_node(node_name):
				hud_canvas.get_node(node_name).visible = false
			else:
				print("Nó", node_name, "não encontrado no CanvasLayer.")
	else:
		print("CanvasLayer não encontrado para configurar a HUD!")

	# Configurar entrada e sinais
	set_process_input(true)
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

	print("Character switch ready")

func _process(delta):
	time_passed += delta
	var new_y = base_position.y + sin(time_passed * float_speed) * float_height
	var t = global_transform
	t.origin.y = new_y
	global_transform = t

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_inside = true
		print("Player entered the area")

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_inside = false
		print("Player exited the area")

func _input(event):
	if player_inside and event.is_action_pressed("ui_interact"):
		print("ui_interact pressed")
		toggle_character()
		
func toggle_character():
	# Salva o estado atual da câmera antes de trocar
	var previous_camera_mode = $"../Camera Switch".current_camera_mode

	if current_character == 0:
		# Salve a vida atual da Libu
		if libu:
			libu_health = libu.current_health
		# Trocar de Libu para Vanessa
		current_character = 1

		# Ocultar barras de vida da Libu e desativar a câmera
		if libu:
			libu.disable_combat()
			deactivate_character(libu)
			libu.reset_shooting_state()
			libu.hide_all_life_bars()
			if libu_camera:
				libu_camera.current = false

		# Instanciar a Vanessa se ainda não estiver na cena
		if vanessa_instance == null:
			vanessa_instance = vanessa_scene.instantiate()
			get_parent().add_child(vanessa_instance)
			vanessa_instance.global_transform = libu.global_transform
			vanessa_camera = vanessa_instance.get_node("VanessaCamera3D")

		# Mostrar barras de vida da Vanessa e ativar a câmera
		if vanessa_instance:
			activate_character(vanessa_instance)
			vanessa_instance.enable_combat()
			vanessa_instance.reset_shooting_state()
			vanessa_instance.show_all_life_bars()
			if vanessa_camera:
				vanessa_camera.current = true
				
		# Sincronize a vida de Vanessa
		if vanessa_instance:
			vanessa_instance.current_health = vanessa_health
			vanessa_instance.update_life_bar()

		print("Switched to Vanessa")

	else:
		
		# Salve a vida atual da Vanessa
		if vanessa_instance:
			vanessa_health = vanessa_instance.current_health
		# Trocar de Vanessa para Libu
		current_character = 0

		# Ocultar barras de vida da Vanessa e desativar a câmera
		if vanessa_instance:
			vanessa_instance.disable_combat()
			deactivate_character(vanessa_instance)
			vanessa_instance.reset_shooting_state()
			vanessa_instance.hide_all_life_bars()
			if vanessa_camera:
				vanessa_camera.current = false

		# Mostrar barras de vida da Libu e ativar a câmera
		if libu:
			activate_character(libu)
			libu.enable_combat()
			libu.reset_shooting_state()
			libu.show_all_life_bars()
			if libu_camera:
				libu_camera.current = true

		# Remover a instância da Vanessa, se necessário
		if vanessa_instance:
			vanessa_instance.queue_free()
			vanessa_instance = null
			vanessa_camera = null

		print("Switched to Libu")

	# 🔹 Sincroniza a câmera do novo personagem com o estado anterior
	sync_camera_state(previous_camera_mode)


func deactivate_character(character):
	if character:
		character.hide()
		character.set_physics_process(false)
		character.set_process(false)

		for collider in character.get_children():
			if collider is CollisionShape3D:
				collider.disabled = true

		# Desativa a lógica de tiro e mira
		if character.has_method("disable_combat"):
			character.disable_combat()

func activate_character(character):
	if character:
		character.show()
		character.set_physics_process(true)
		character.set_process(true)

		for collider in character.get_children():
			if collider is CollisionShape3D:
				collider.disabled = false

		# Ativa a lógica de tiro e mira
		if character.has_method("enable_combat"):
			character.enable_combat()

func update_camera():
	if current_character == 0:
		var libu_camera = libu.get_node("LibuCamera3D")
		if libu_camera:
			libu_camera.make_current()
			print("Câmera ativa: LibuCamera3D")
	else:
		if vanessa_instance:
			var vanessa_camera = vanessa_instance.get_node("VanessaCamera3D")
			if vanessa_camera:
				vanessa_camera.make_current()
				print("Câmera ativa: VanessaCamera3D")


func update_hud(active_character):
	hide_all_life_bars()  # Primeiro, esconde todas as barras de vida

	# Exibe a barra de vida do personagem ativo
	if active_character == libu:
		# Atualiza a barra de vida da Libu com base na vida atual
		if libu.current_health == 2:
			hud_libu.get_node("HUD_Life_Full_Libu").visible = true
		elif libu.current_health == 1:
			hud_libu.get_node("HUD_Life_Hurt_Libu").visible = true
		elif libu.current_health <= 0:
			hud_libu.get_node("HUD_Life_Dead_Libu").visible = true
	elif active_character == vanessa_instance:
		# Atualiza a barra de vida da Vanessa com base na vida atual
		if vanessa_instance.current_health == 4:
			hud_vanessa.get_node("HUD_Life_Full_Vanessa").visible = true
		elif vanessa_instance.current_health == 3:
			hud_vanessa.get_node("HUD_Life_Hurt_Vanessa").visible = true
		elif vanessa_instance.current_health == 2:
			hud_vanessa.get_node("HUD_Life_Hurt2_Vanessa").visible = true
		elif vanessa_instance.current_health == 1:
			hud_vanessa.get_node("HUD_Life_Hurt3_Vanessa").visible = true
		elif vanessa_instance.current_health <= 0:
			hud_vanessa.get_node("HUD_Life_Dead_Vanessa").visible = true

		
func hide_all_life_bars():
	# Esconde todas as barras de vida da Libu
	hud_libu.get_node("HUD_Life_Full_Libu").visible = false
	hud_libu.get_node("HUD_Life_Hurt_Libu").visible = false
	hud_libu.get_node("HUD_Life_Dead_Libu").visible = false
	
	# Esconde todas as barras de vida da Vanessa
	hud_vanessa.get_node("HUD_Life_Full_Vanessa").visible = false
	hud_vanessa.get_node("HUD_Life_Hurt_Vanessa").visible = false
	hud_vanessa.get_node("HUD_Life_Hurt2_Vanessa").visible = false
	hud_vanessa.get_node("HUD_Life_Hurt3_Vanessa").visible = false
	hud_vanessa.get_node("HUD_Life_Dead_Vanessa").visible = false
	
func sync_camera_state(camera_mode = null):
	# Sincroniza o estado da câmera ao trocar de personagem
	if camera_mode == null:
		camera_mode = $"../Camera Switch".current_camera_mode

	if current_character == 0 and libu_camera:
		if camera_mode == 0:
			libu_camera.deactivate_side_scroll()
			libu_camera.deactivate_first_person()
		elif camera_mode == 1:
			libu_camera.activate_side_scroll()
		elif camera_mode == 2:
			libu_camera.activate_first_person()

	elif current_character == 1 and vanessa_camera:
		if camera_mode == 0:
			vanessa_camera.deactivate_side_scroll()
			vanessa_camera.deactivate_first_person()
		elif camera_mode == 1:
			vanessa_camera.activate_side_scroll()
		elif camera_mode == 2:
			vanessa_camera.activate_first_person()
