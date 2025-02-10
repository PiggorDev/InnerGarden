extends Camera3D

# Parâmetros ajustáveis
@export var player: CharacterBody3D
@export var offset_distance: float = 10.0
@export var height: float = 5.0
@export var transparency: float = 0.4
@export var restore_opacity: float = 1.0
@onready var raycast = $RayCast3D
@onready var transparency_area_1: Area3D = $Transparency1
@onready var transparency_area_2: Area3D = $Transparency2
@onready var VanessaShape = $"../VanessaShape"
@onready var eyes = $"../eyes"  # Referência ao nó 3D chamado "eyes"
@onready var mesh_instance = $"../Sprite3D"
@onready var crosshair = $CrossHair/Mira # Caminho até o nó do crosshair
# Valores máximos e mínimos para o zoom
@export var max_offset_distance: float = 15.0
@export var min_offset_distance: float = 4.0
@export var max_height: float = 10.0
@export var min_height: float = 2.0
@export var zoom_speed: float = 1.0  # Velocidade de zoom



@export var sensitivity: float = 0.1
@export var min_pitch: float = -80
@export var max_pitch: float = 80
@export var transparency_group: String = "Transparantable"
@export var eye_height: float = 1.5  # Altura relativa dos olhos do personagem


# Parâmetros para side-scroll
@export var side_scroll_offset: Vector3 = Vector3(20, 10, 0)
@export var transition_time: float = 0.4
signal first_person_toggled(active)
var is_inventory_open: bool = false
var initial_camera_offset: Vector3 = Vector3.ZERO
var last_mouse_movement: Vector2 = Vector2.ZERO


# Variáveis internas
var saved_distance: float = 0.0
var saved_height: float = 0.0
# Variáveis para armazenar o estado da câmera
var saved_camera_position: Vector3 = Vector3.ZERO
var saved_camera_rotation: Vector3 = Vector3.ZERO
var camera_offset: Vector3 = Vector3(0, 5, -10)  # Padrão de offset da câmera

var transparent_objects: Array = []
var all_overrides: Dictionary = {}
var yaw: float = 0
var pitch: float = 0
var is_side_scroll_active: bool = false
var target_position: Vector3 = Vector3.ZERO
var transitioning: bool = false
var is_first_person_active: bool = false
var is_camera_locked: bool = false


func _ready():
	if not player:
		player = get_parent()
		if not player:
			print("Erro: jogador (player) não configurado!")
			return
	print("Câmera configurada com o jogador: ", player.name)
	raycast.enabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	yaw = rotation_degrees.y
	pitch = rotation_degrees.x
	
	# Salva o offset inicial da câmera em relação ao jogador
	initial_camera_offset = global_transform.origin - player.global_transform.origin
	# Conectar os sinais das áreas


func _input(event):
	if Global.is_inventory_open:
		return
	if is_camera_locked:
		return  # Bloqueia a rotação da câmera
	
	# 📌 Zoom da câmera com a roda do mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			offset_distance = max(offset_distance - zoom_speed, min_offset_distance)
			height = max(height - zoom_speed * 0.6, min_height)  # Ajuste para manter proporção
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			offset_distance = min(offset_distance + zoom_speed, max_offset_distance)
			height = min(height + zoom_speed * 0.6, max_height)

	if event is InputEventMouseMotion:
		if is_first_person_active:
			yaw -= event.relative.x * sensitivity
			pitch -= event.relative.y * sensitivity
			pitch = clamp(pitch, min_pitch, max_pitch)
		else:
			yaw -= event.relative.x * sensitivity
			pitch -= event.relative.y * sensitivity
			pitch = clamp(pitch, min_pitch, max_pitch)

		rotation_degrees = Vector3(pitch, yaw, 0)


func _process(delta):
	if Global.is_inventory_open:
		return  # Bloqueia toda movimentação e rotação da câmera

	manage_transparency()
	

	
	if player:
		if transitioning:
			_update_transition(delta)
		elif is_side_scroll_active:
			_update_side_scroll_position()
		elif not is_first_person_active:  # Só atualiza a câmera se não estiver no modo de primeira pessoa
			_update_camera_position()


func _update_camera_position():
	var horizontal_offset = Vector3(
		offset_distance * sin(deg_to_rad(yaw)),
		0,
		offset_distance * cos(deg_to_rad(yaw))
	)
	global_transform.origin = player.global_transform.origin + horizontal_offset
	global_transform.origin.y = player.global_transform.origin.y + height
	look_at(player.global_transform.origin, Vector3.UP)


func _update_side_scroll_position():
	var side_scroll_target_position = player.global_transform.origin + side_scroll_offset
	global_transform.origin = side_scroll_target_position
	look_at(player.global_transform.origin, Vector3.UP)

func _update_transition(delta):
	var target_position: Vector3
	if is_side_scroll_active:
		target_position = player.global_transform.origin + side_scroll_offset
	else:
		target_position = _calculate_normal_camera_position()
	global_transform.origin = global_transform.origin.lerp(target_position, delta / transition_time)
	look_at(player.global_transform.origin, Vector3.UP)
	if global_transform.origin.distance_to(target_position) < 0.1:
		transitioning = false
		if is_side_scroll_active:
			_update_side_scroll_position()
		else:
			_update_camera_position()
		if not is_side_scroll_active:
			_restore_mouse_control()

func _calculate_normal_camera_position() -> Vector3:
	return player.global_transform.origin + Vector3(
		offset_distance * sin(deg_to_rad(yaw)),
		height,
		offset_distance * cos(deg_to_rad(yaw))
	)

func activate_side_scroll():
	if not is_side_scroll_active:
		is_side_scroll_active = true
		is_first_person_active = false
		transitioning = true

		# Certifique-se de capturar o mouse mesmo no modo Side Scroll
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)




func _restore_mouse_control():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Gerencia a transparência dos objetos obstruindo o jogador
# Gerencia a transparência dos objetos obstruindo o jogador
func manage_transparency():
	# Restaura opacidade e remove overrides de todos os objetos previamente transparentes
	for obj in transparent_objects:
		if obj and obj.material_override:
			obj.material_override = null  # Remove completamente o material override
			print("Material override removido de: ", obj.name)
	transparent_objects.clear()

	# Calcula o ponto entre a câmera e o jogador
	var camera_position = global_transform.origin
	var player_position = player.global_transform.origin
	var direction = player_position - camera_position
	var max_distance = direction.length()
	direction = direction.normalized()  # Normaliza o vetor direção

	# Cria um RayQuery para verificar objetos entre a câmera e o jogador
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = camera_position
	query.to = player_position
	query.exclude = [self, player]  # Exclui a câmera e o jogador da detecção
	query.collide_with_bodies = true
	query.collide_with_areas = false

	# Realiza a detecção de colisão
	var result = space_state.intersect_ray(query)

	if result and result.collider:
		var collider = result.collider
		var parent = collider.get_parent()
		while parent:
			if parent.is_in_group(transparency_group):
				var mesh_instance = find_mesh_instance(parent)
				if mesh_instance:
					_apply_transparency(mesh_instance)
					return
			parent = parent.get_parent()

func _apply_transparency(mesh_instance: MeshInstance3D):
	if not mesh_instance.material_override:
		mesh_instance.material_override = StandardMaterial3D.new()
		mesh_instance.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mesh_instance.material_override.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	mesh_instance.material_override.albedo_color.a = transparency
	if mesh_instance not in transparent_objects:
		transparent_objects.append(mesh_instance)
	print("Transparência aplicada a: ", mesh_instance.name)
	
func _remove_transparency(mesh_instance: MeshInstance3D):
	if mesh_instance in transparent_objects:
		mesh_instance.material_override = null  # Remove completamente o material override
		transparent_objects.erase(mesh_instance)
		print("Transparência removida de: ", mesh_instance.name)
	
func find_mesh_instance(node):
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
	return null

	
	# Quando um corpo entra na área
func _on_body_entered_area(body):
	if body.is_in_group(transparency_group):
		var mesh_instance = find_mesh_instance(body)
		if mesh_instance:
			_apply_transparency(mesh_instance)

# Quando um corpo sai da área
func _on_body_exited_area(body):
	if body.is_in_group(transparency_group):
		var mesh_instance = find_mesh_instance(body)
		if mesh_instance:
			_remove_transparency(mesh_instance)

func activate_first_person():
	if not is_first_person_active:
		is_first_person_active = true
		is_side_scroll_active = false
		transitioning = false
		emit_signal("first_person_toggled", true)

		# Centraliza a câmera no modo de primeira pessoa
		var camera = get_viewport().get_camera_3d()
		if eyes:
			global_transform.origin = eyes.global_transform.origin

		# Faz a câmera olhar para frente
		look_at(global_transform.origin + -camera.global_transform.basis.z, Vector3.UP)

		# Mostra o crosshair no modo de primeira pessoa
		if crosshair:
			crosshair.visible = true

		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func deactivate_first_person():
	if is_first_person_active:
		is_first_person_active = false
		emit_signal("first_person_toggled", false)

		# Esconde o crosshair fora do modo de primeira pessoa
		if crosshair:
			crosshair.visible = false

		# Mantém o mouse capturado para esconder o cursor
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func deactivate_side_scroll():
	if is_side_scroll_active:
		is_side_scroll_active = false
		transitioning = true

func fix_camera_before_inventory():
	# Atualiza a rotação final antes de bloquear os inputs
	rotation_degrees = Vector3(pitch, yaw, 0)
	global_transform.origin = _calculate_normal_camera_position()

func save_camera_state():
	saved_camera_position = global_transform.origin
	saved_camera_rotation = rotation_degrees
	
	# Calcula e salva a distância relativa em relação ao jogador
	if player:
		saved_distance = global_transform.origin.distance_to(player.global_transform.origin)
		saved_height = global_transform.origin.y - player.global_transform.origin.y

func restore_camera_state():
	if player:
		# Mantém a mesma posição relativa da câmera ao jogador, preservando o offset inicial
		global_transform.origin = player.global_transform.origin + initial_camera_offset
		look_at(player.global_transform.origin, Vector3.UP)

	rotation_degrees = saved_camera_rotation


func center_camera_on_player():
	if not player:
		print("Player não atribuído à câmera!")
		return false  # Retorna false se não conseguiu centralizar
	
	# Reposiciona a câmera relativa ao jogador
	global_transform.origin = player.global_transform.origin + camera_offset
	
	# Faz a câmera olhar para o jogador
	look_at(player.global_transform.origin, Vector3.UP)
	return true  # Indica que centralizou com sucesso


func lock_camera():
	is_camera_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Libera o cursor

func unlock_camera():
	is_camera_locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Captura o cursor de novo
