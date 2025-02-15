extends Area3D

@export var speed: float = 10.0
@export var lifetime: float = 5.0
@export var damage: int = 5

var direction: Vector3 = Vector3.ZERO
var target: Node = null
var shooter: Node = null

@onready var damage_shape = $DAMAGE
@onready var collision_shape = $COLLISION
@onready var sprite = $Sprite3D

func _ready():
	# Desativa colisões brevemente para evitar problemas iniciais
	damage_shape.disabled = true
	collision_shape.disabled = true
	await get_tree().create_timer(0.05).timeout
	damage_shape.disabled = false
	collision_shape.disabled = false

	# Remove o projétil após o tempo de vida acabar
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func set_velocity(dir: Vector3):
	if dir == Vector3.ZERO:
		dir = Vector3(0, 0, 1)  # Direção padrão se nenhuma for definida
	direction = dir.normalized()

func set_target(new_target: Node):
	target = new_target
	if target and is_instance_valid(target):
		direction = (target.global_transform.origin - global_transform.origin).normalized()
		print("🔹 Projétil carregado recebeu alvo:", target.name)

func _process(delta):
	# Se tem um alvo, continua seguindo ele
	if target and is_instance_valid(target) and target.is_inside_tree():
		var target_position = target.global_transform.origin
		direction = (target_position - global_transform.origin).normalized()

	# Movimento do projétil
	if direction != Vector3.ZERO:
		global_transform.origin += direction * speed * delta
	else:
		print("⚠️ Aviso: Direção do projétil carregado é ZERO.")

	update_sprite_orientation()

func update_sprite_orientation():
	if sprite and get_viewport().get_camera_3d():
		var camera_position = get_viewport().get_camera_3d().global_transform.origin
		sprite.look_at(camera_position, Vector3.UP)
		sprite.rotation.x = 0
		sprite.rotation.z = 0

# Colisão com inimigos (hitbox de dano)
func _on_DAMAGE_body_entered(body):
	if body == shooter:
		return

	if body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("🔥 Inimigo atingido pelo tiro carregado! Dano causado:", damage)
		queue_free()

# Colisão com objetos que destroem o projétil
func _on_COLLISION_body_entered(body):
	if body == shooter:
		return

	if body is StaticBody3D or body is RigidBody3D:
		print("💥 Projétil carregado colidiu com um objeto!")
		queue_free()
