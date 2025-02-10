extends Area3D

@export var speed: float = 10.0  # Velocidade do projétil
@export var lifetime: float = 5.0  # Tempo de vida do projétil
@export var damage: int = 1  # Dano causado pelo projétil

var direction: Vector3 = Vector3.ZERO  # Direção do projétil
var target: Node = null  # Alvo teleguiado
var time_elapsed: float = 0.0  # Tempo decorrido desde o disparo
var origin_y: float = 0.0  # Armazena a altura inicial do projétil

@onready var sprite = $Sprite3D  # Referência ao Sprite3D do projétil

func _ready():
	# Salva a altura inicial do projétil
	origin_y = global_transform.origin.y

	# Desativa colisões no início para evitar colisões imediatas
	await get_tree().create_timer(0.1).timeout
	$CollisionShape3D.disabled = false

	# Remove o projétil após o tempo de vida acabar
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func set_velocity(dir: Vector3):
	direction = dir.normalized()

func set_target(new_target: Node):
	target = new_target
	if target and is_instance_valid(target):
		direction = (target.global_transform.origin - global_transform.origin).normalized()

func _process(delta):
	if target:
		if is_instance_valid(target) and target.is_inside_tree():
			var target_position = target.global_transform.origin
			direction = (target_position - global_transform.origin).normalized()
		else:
			target = null

	global_transform.origin += direction * speed * delta

	update_sprite_orientation()

func _on_body_entered(body):
	# Obtém a altura (Y) do ponto de colisão
	var collision_y = body.global_transform.origin.y

	# Ignora colisões com o jogador
	if body.is_in_group("Player"):
		return  # Não destrói o projétil ao colidir com o jogador

	# Verifica se a colisão está na mesma altura do disparo
	if abs(collision_y - origin_y) < 0.1:  # Margem de tolerância de 0.1 unidades
		print("Ignorando colisão com superfície na mesma altura do disparo")
		return

	# Colisão com inimigos
	if body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)  # Aplica dano chamando o método do inimigo
			print("Vida restante do inimigo: ", body.health)

		queue_free()  # Remove o projétil após causar dano

	# Colisão com outros objetos
	elif body is PhysicsBody3D or body is StaticBody3D or body is RigidBody3D:
		queue_free()  # Remove o projétil ao colidir com outros objetos

func update_sprite_orientation():
	if sprite and get_viewport().get_camera_3d():
		var camera_position = get_viewport().get_camera_3d().global_transform.origin
		sprite.look_at(camera_position, Vector3.UP)
		sprite.rotation.x = 0
		sprite.rotation.z = 0
