extends Node3D

@export var shadow_texture: Texture2D:
	set(value):
		if shadow_sprite != null:  # Verifica se o sprite já foi inicializado
			shadow_sprite.texture = value
		else:
			print("Aviso: ShadowSprite não encontrado durante atribuição de textura")

@export var max_height: float = 10.0
@export var min_scale: float = 0.5
@export var max_scale: float = 1.5
@export var shadow_offset: float = 0.1

@onready var shadow_sprite: Sprite3D = $ShadowSprite
@onready var shadow_raycast: RayCast3D = $ShadowRayCast

var _parent: Node3D

func _ready():
	_parent = get_parent()
	if shadow_raycast != null:
		shadow_raycast.add_exception(_parent)
		shadow_raycast.target_position = Vector3.DOWN * max_height
	else:
		push_error("RayCast3D não encontrado!")

	# Garante que a textura seja aplicada após a inicialização
	if shadow_texture != null && shadow_sprite != null:
		shadow_sprite.texture = shadow_texture

func _process(delta):

	if shadow_raycast.is_colliding() and shadow_sprite != null:
		# Obtém o objeto colidido
		var collider = shadow_raycast.get_collider()

		# Verifica se o collider é válido antes de prosseguir
		if collider and (collider is MeshInstance3D or collider is StaticBody3D or collider.is_in_group("shadow_receiver")):
			var collision_point = shadow_raycast.get_collision_point()
			var height = _parent.global_position.y - collision_point.y

			shadow_sprite.global_position = collision_point + Vector3.UP * shadow_offset
			shadow_sprite.scale = Vector3.ONE * lerp(max_scale, min_scale, clamp(height / max_height, 0.0, 1.0))
			shadow_sprite.visible = true
		else:
			# Se não for um objeto válido, oculta a sombra
			shadow_sprite.visible = false
	elif shadow_sprite != null:
		shadow_sprite.visible = false
