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
var transitioning: bool = false
var saved_offset_distance: float
var saved_camera_position: Vector3
var saved_camera_rotation: Vector3
var target_position: Vector3
var transition_progress: float = 0.0
var is_camera_locked: bool = false
var is_first_person_active: bool = false:
	set(value):
		print("🚨 is_first_person_active mudou! NOVO VALOR:", value, " | Chamado por:", get_stack())
		is_first_person_active = value
func _ready():
	# 🔥 Garante que a câmera inicie na distância máxima de zoom out
	offset_distance = 8.0  
	_update_camera_position()

func _process(delta):
	print("🎥 Estado Atual da Câmera - FPS Ativo?", is_first_person_active)

	if is_first_person_active:
		print("✅ FPS ATIVO - NÃO DEVE ALTERAR")
		_update_first_person_camera()
		return

	if is_side_scroll_active:
		print("⚠️ Modo Side Scroll está ativo, pode estar interferindo")
		_update_side_scroll_position()
		return

	if transitioning:
		print("🔄 Transição de câmera está rodando, pode ser isso")
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

	# 🔹 **FORÇA a posição exata no jogador**
	global_transform.origin = player.global_transform.origin + side_scroll_offset

	# 🔹 **Força a rotação EXATA**
	global_rotation_degrees = Vector3(0, side_scroll_rotation_angle, 0)

	# 🔹 **Mantém o eixo Z sempre fixo**
	global_transform.origin.z = player.global_transform.origin.z

	# 🔹 **Evita qualquer movimentação indevida**
	force_update_transform()


func _update_transition(delta):
	transition_progress += delta / transition_time
	transition_progress = clamp(transition_progress, 0.0, 1.0)
	global_transform.origin = global_transform.origin.lerp(target_position, transition_progress)

	if transition_progress >= 1.0:
		transitioning = false

func activate_side_scroll():
	print("🎥 FORÇANDO Side Scroll - Resetando tudo!")

	if is_side_scroll_active:
		return

	is_side_scroll_active = true
	transitioning = false  # Evita transições desnecessárias

	# 🔹 Salva os valores antes de mudar para Side Scroll
	saved_camera_position = global_transform.origin
	saved_camera_rotation = rotation_degrees
	saved_offset_distance = offset_distance

	# 🔥 **ZERA COMPLETAMENTE A TRANSFORMAÇÃO PARA EVITAR RESÍDUOS**
	global_transform = Transform3D.IDENTITY
	rotation_degrees = Vector3.ZERO

	# 🔥 **REMOVE QUALQUER MOVIMENTO INDESEJADO DO CameraPivot**
	if camera_pivot:
		camera_pivot.rotation_degrees = Vector3.ZERO
		camera_pivot.global_transform.origin = player.global_transform.origin
		camera_pivot.set_process(false)  # 🚫 Bloqueia a atualização do pivot

	# 🔥 **Força a posição EXATA do Side Scroll**
	global_transform.origin = player.global_transform.origin + side_scroll_offset

	# 🔥 **Força a rotação EXATA para 90 graus**
	global_rotation_degrees = Vector3(0, side_scroll_rotation_angle, 0)

	# 🔹 **Garante que a câmera NÃO se mova no eixo Z**
	global_transform.origin.z = player.global_transform.origin.z

	# 🔹 **Força a câmera a atualizar instantaneamente**
	force_update_transform()

	# 🔹 **Bloqueia outras atualizações para não sobrescrever**
	is_camera_locked = true
	set_process(false)

	# 🔹 Captura o mouse apenas para cliques, sem movimentação de câmera
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	print("✅ Side Scroll ativado com posição e rotação FIXAS!")

func deactivate_side_scroll():
	if not is_side_scroll_active:
		return

	print("🚨 Resetando Câmera - Saindo do Side Scroll!")

	is_side_scroll_active = false
	transitioning = true
	transition_progress = 0.0

	# **Restaura a posição e a rotação da câmera**
	target_position = saved_camera_position
	rotation_degrees = saved_camera_rotation
	offset_distance = saved_offset_distance

	# 🔹 **Reativa o CameraPivot**
	if camera_pivot:
		camera_pivot.set_process(true)  # 🔥 Reativa o pivot
		camera_pivot.rotation_degrees = Vector3.ZERO

	# 🔹 **Desbloqueia a câmera**
	is_camera_locked = false
	set_process(true)

	# 🔹 **Captura o cursor novamente**
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	print("✅ Modo terceira pessoa restaurado corretamente!")

### 🔥 **FPS (Primeira Pessoa)**
func activate_first_person():
	print("🎥 Ativando Modo Primeira Pessoa! [ANTES] is_first_person_active:", is_first_person_active)

	# 🔹 FORÇA a ativação do modo FPS
	is_first_person_active = true

	print("✅ [DEPOIS] is_first_person_active AGORA ESTÁ:", is_first_person_active)  # Debug

	# 🔹 Desativa outros modos
	is_side_scroll_active = false
	transitioning = false

	# 🔹 Salva a posição da câmera
	saved_camera_position = global_transform.origin
	saved_camera_rotation = rotation_degrees

	# 🔹 Move a câmera para os olhos do jogador
	global_transform.origin = player.global_transform.origin + Vector3(0, eye_height, 0)
	rotation_degrees = Vector3.ZERO

	# 🔹 Ativa captura total do mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func deactivate_first_person():
	print("🚨 Desativando Primeira Pessoa! is_first_person_active será FALSE")

	# Garante que só executa se estiver realmente no modo primeira pessoa
	if not is_first_person_active:
		print("⚠️ Tentativa de desativar primeira pessoa quando já estava desativado.")
		return

	# Define estado correto
	is_first_person_active = false
	transitioning = true
	transition_progress = 0.0

	print("🔄 Restaurando posição e rotação da câmera para terceira pessoa...")
	target_position = saved_camera_position
	rotation_degrees = saved_camera_rotation

	# 🔹 Retorna o controle normal da câmera IMEDIATAMENTE sem precisar de input
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("🎥 Cursor capturado e câmera retornando para terceira pessoa automaticamente!")

	# Garante que a câmera volte para a posição correta
	_update_camera_position()

	print("✅ Modo terceira pessoa restaurado com sucesso!")

func _update_first_person_camera():
	if not player:
		return  # Evita erro se o player não estiver definido

	# 🔹 Mantém a posição da câmera na altura dos olhos do jogador
	global_transform.origin = player.global_transform.origin + Vector3(0, eye_height, 0)

	# 🔥 O YAW (esquerda/direita) ainda segue a rotação do jogador
	global_rotation_degrees.y = player.global_rotation_degrees.y  

	# 🔥 O PITCH (cima/baixo) é independente e ajustado pelo input do mouse
	global_rotation_degrees.x = clamp(global_rotation_degrees.x, -89, 89)


# 🚀 **Função para desativar atualizações automáticas da câmera no Side Scroll**
func _disable_camera_updates():
	transitioning = false  # Evita qualquer transição automática
	is_camera_locked = true  # Bloqueia outras atualizações

	# **Desativa qualquer função que possa sobrescrever a rotação**
	set_process(false)
	set_physics_process(false)

	# 🚀 Removemos is_first_person_active = false para evitar resetar a câmera FPS!
	print("⚠️ _disable_camera_updates() chamado, mas FPS não será alterado automaticamente.")
