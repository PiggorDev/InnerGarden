extends Camera3D

# 📌 Parâmetros da câmera
@export var player: CharacterBody3D
@export var offset_distance: float = 10.0
@export var height: float = 5.0
@export var transparency: float = 0.4
@export var zoom_speed: float = 0.5  
@export var side_scroll_offset: Vector3 = Vector3(10, 5, 0)
@export var transition_time: float = 0.4
@export var eye_height: float = 1.5  
@export var side_scroll_rotation_angle: float = 90.0  # 🌀 Ângulo de rotação da câmera no modo Side Scroll

@onready var camera_pivot = get_parent()

var is_side_scroll_active: bool = false
var is_first_person_active: bool = false
var transitioning: bool = false
var saved_offset_distance: float
var saved_camera_position: Vector3
var saved_camera_rotation: Vector3
var target_position: Vector3
var transition_progress: float = 0.0
var is_camera_locked: bool = false


func _process(delta):

	if is_side_scroll_active:
		_update_side_scroll_position()
		return

	if is_first_person_active:
		_update_first_person_camera()
		return

	if transitioning:
		_update_transition(delta)
	else:
		_update_camera_position()

func _update_camera_position():
	if not player or not camera_pivot:
		return

	camera_pivot.global_transform.origin = player.global_transform.origin
	var direction = -camera_pivot.global_transform.basis.z.normalized()
	global_transform.origin = camera_pivot.global_transform.origin + (direction * offset_distance)
	look_at(camera_pivot.global_transform.origin, Vector3.UP)

func _input(event):
	# 🚫 Bloqueia qualquer influência do mouse caso esteja no Side Scroll
	if is_side_scroll_active and (event is InputEventMouseMotion or event is InputEventMouseButton):
		return  

	# 🚀 **Bloqueia cliques do mouse no modo de primeira pessoa**
	if is_first_person_active and event is InputEventMouseButton:
		return  # 🔥 Sai da função sem alterar nada se estiver em primeira pessoa

	# 🎮 Controle de Zoom (rodinha do mouse) - Somente se NÃO estiver no modo Side Scroll
	if event is InputEventMouseButton and not is_side_scroll_active:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			offset_distance = max(2.0, offset_distance - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			offset_distance = min(8.0, offset_distance + zoom_speed)
		_update_camera_position()


func _update_side_scroll_position():
	if not player:
		return

	var side_scroll_target_position = player.global_transform.origin + side_scroll_offset
	side_scroll_target_position.z = global_transform.origin.z  
	global_transform.origin = global_transform.origin.lerp(side_scroll_target_position, 0.15)
	global_transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))

	if camera_pivot:
		camera_pivot.rotation_degrees = Vector3.ZERO
		camera_pivot.global_transform.origin = player.global_transform.origin

func _update_transition(delta):
	transition_progress += delta / transition_time
	transition_progress = clamp(transition_progress, 0.0, 1.0)
	global_transform.origin = global_transform.origin.lerp(target_position, transition_progress)

	if transition_progress >= 1.0:
		transitioning = false

func activate_side_scroll():
	if not is_side_scroll_active:
		is_side_scroll_active = true
		transitioning = false  # Evita transições desnecessárias

		# 🔹 Salva os valores antes de mudar para Side Scroll
		saved_camera_position = global_transform.origin
		saved_camera_rotation = camera_pivot.rotation_degrees
		saved_offset_distance = offset_distance

		# 🔹 Move a câmera diretamente para o offset do Side Scroll
		global_transform.origin = player.global_transform.origin + side_scroll_offset

		# 🔍 Depuração: Confirma se o ângulo está correto
		print("🔄 Aplicando rotação Side Scroll com ângulo:", side_scroll_rotation_angle)

		# 🔹 Aplica a rotação diretamente na **câmera**
		rotation_degrees = Vector3(0, side_scroll_rotation_angle, 0)

		# 🔹 **Se o camera_pivot estiver interferindo, reseta ele**
		if camera_pivot:
			camera_pivot.rotation_degrees = Vector3.ZERO
			camera_pivot.global_transform.origin = player.global_transform.origin

		# 🔹 **Força a atualização da transformação**
		force_update_transform()

		# 🔹 **Desativa qualquer interpolação automática da câmera**
		_disable_camera_updates()

		# 🔹 Captura o mouse apenas para cliques, sem movimentação de câmera
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func deactivate_side_scroll():
	if not is_side_scroll_active:
		return

	is_side_scroll_active = false
	transitioning = true
	transition_progress = 0.0
	target_position = camera_pivot.global_transform.origin + Vector3(0, height, -offset_distance)
	offset_distance = saved_offset_distance
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

### 🔥 **FPS (Primeira Pessoa)**
func activate_first_person():
	if is_first_person_active:
		return

	is_first_person_active = true
	is_side_scroll_active = false
	transitioning = false

	saved_camera_position = global_transform.origin
	saved_camera_rotation = rotation_degrees

	# 🔹 Move a câmera para os olhos do jogador
	global_transform.origin = player.global_transform.origin + Vector3(0, eye_height, 0)
	rotation_degrees = Vector3.ZERO

	# 🔹 Ativa captura total do mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func deactivate_first_person():
	if not is_first_person_active:
		return

	is_first_person_active = false
	transitioning = true
	transition_progress = 0.0

	target_position = saved_camera_position
	rotation_degrees = saved_camera_rotation

	# 🔹 Retorna o controle normal da câmera
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _update_first_person_camera():
	if not player:
		return  # Evita erro se o player não estiver definido

	# 🔹 Define a posição da câmera para os "olhos" do jogador
	global_transform.origin = player.global_transform.origin + Vector3(0, eye_height, 0)

	# 🔹 A rotação da câmera segue a do jogador para manter um comportamento de FPS
	global_transform.basis = player.global_transform.basis


# 🚀 **Função para desativar atualizações automáticas da câmera no Side Scroll**
func _disable_camera_updates():
	transitioning = false  # Evita qualquer transição automática
	is_first_person_active = false  # Certifica que não está em primeira pessoa
	is_camera_locked = true  # Bloqueia outras atualizações

	# **Desativa qualquer função que possa sobrescrever a rotação**
	set_process(false)
	set_physics_process(false)
