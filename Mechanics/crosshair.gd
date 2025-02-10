extends Node3D

# Controla se o crosshair está ativo
var is_active: bool = false
@onready var sprite = $Sprite3D  # Substitua pelo caminho correto para o Sprite3D do projétil

func _ready():
	# Inicializa o estado do crosshair
	is_active = false
	visible = false

# Define se o crosshair está ativo e ajusta a visibilidade
func set_active(active: bool):
	is_active = active
	visible = active

# Atualiza a posição do crosshair no espaço global (evitando conflito com Node2D)
func update_position(global_position: Vector3):
	# Converte Vector3 para Vector2 (ignora o eixo Y)
	position = Vector3(global_position.x, global_position.z, global_position.y)

# Atualiza a orientação do sprite para apontar para a câmera
func _process(_delta):
	update_sprite_orientation()

func update_sprite_orientation():
	if sprite and get_viewport().get_camera_3d():
		var camera_position = get_viewport().get_camera_3d().global_transform.origin
		sprite.look_at(camera_position, Vector3.UP)
		sprite.rotation.x = 0
		sprite.rotation.z = 0
