extends CharacterBody3D

@export var patrol_speed: float = 2.0
@export var chase_speed: float = 5.0
@export var vision_radius: float = 5.0
@export var health: int = 5
@export var min_fall_height: float = 5.0
@export var patrol_min_time: float = 2.0
@export var patrol_max_time: float = 5.0
@export var stop_chance: float = 0.1  # 10% de chance de parar
@export var knockback_duration: float = 0.3  # Duração do empurrão em segundos
@export var knockback_force: float = 5.0  # Força do empurrão
@export var hurt_duration: float = 0.2  # Tempo que o inimigo permanece piscando
@export var hurt_color: Color = Color(1, 0, 0)  # Cor avermelhada para o estado de dano

@onready var raycast_front = $RayFront
@onready var vision_area = $VisionArea
@onready var death_area = $DeathArea
@onready var sprite = $Sprite3D  # Referência ao Sprite3D do inimigo
@onready var original_color: Color = $Sprite3D.modulate  # Cor original do inimigo
@onready var inventory = $"../CanvasLayer/Slot container"  # Ajuste o caminho para o Slot Container


var is_hurt: bool = false  # Controla se o inimigo está em estado de dano
var hurt_timer: float = 0.0  # Duração do estado de dano
var target_player: Node = null
var direction: Vector3 = Vector3.ZERO
var is_chasing: bool = false
var patrol_timer: float = 0.0
var is_stopped: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO  # Velocidade do empurrão
var knockback_timer: float = 0.0  # Tempo restante do empurrão

@onready var vision_shape = $VisionArea/VisionShape

func _ready():
	is_chasing = false
	reset_patrol_timer()
	choose_new_direction()

	# Configura o raio de visão
	if vision_shape and vision_shape.shape and vision_shape.shape is SphereShape3D:
		vision_shape.shape.radius = vision_radius

	# Ativa o RayCast
	raycast_front.enabled = true

func _physics_process(delta):
	apply_gravity(delta)

	if hurt_timer > 0:
		hurt_timer -= delta
		if hurt_timer <= 0:
			is_hurt = false
			$Sprite3D.modulate = original_color  # Restaura a cor original

	if is_hurt:
		# Faz o inimigo piscar alternando a cor
		$Sprite3D.modulate = hurt_color if int(hurt_timer * 10) % 2 == 0 else original_color

	if is_chasing and target_player:
		chase_player(delta)
	else:
		patrol(delta)

	update_sprite_orientation()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0

func patrol(delta):
	patrol_timer -= delta

	if patrol_timer <= 0:
		reset_patrol_timer()

	if not is_stopped:
		if is_near_edge():
			choose_new_direction()
		else:
			velocity.x = direction.x * patrol_speed
			velocity.z = direction.z * patrol_speed
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func chase_player(_delta):
	if not target_player:
		is_chasing = false
		return

	var to_player = (target_player.global_transform.origin - global_transform.origin).normalized()
	to_player.y = 0  # Ignora a altura para perseguição plana

	velocity.x = to_player.x * chase_speed
	velocity.z = to_player.z * chase_speed

	move_and_slide()

func is_near_edge() -> bool:
	var raycast_origin = global_transform.origin
	var raycast_target = raycast_origin + direction * 2.0
	raycast_target.y -= 10  # Projeta o RayCast para baixo

	# Configura os parâmetros do RayCast
	var query = PhysicsRayQueryParameters3D.new()
	query.from = raycast_origin
	query.to = raycast_target
	query.exclude = [self]  # Exclui o próprio inimigo

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	if result == null:
		return true

	if not result.has("position"):
		return true

	var collision_point = result["position"]
	if raycast_origin.y - collision_point.y > min_fall_height:
		return true

	return false

func choose_new_direction():
	var attempts = 10  # Número de tentativas para encontrar uma direção segura
	for i in range(attempts):
		var test_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		if not will_fall_in_direction(test_direction):
			direction = test_direction
			return

func will_fall_in_direction(test_direction: Vector3) -> bool:
	var raycast_origin = global_transform.origin
	var raycast_target = raycast_origin + test_direction * 2.0
	raycast_target.y -= 10  # Projeta o RayCast para baixo

	var query = PhysicsRayQueryParameters3D.new()
	query.from = raycast_origin
	query.to = raycast_target
	query.exclude = [self]

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	if result == null:
		return true

	if not result.has("position"):
		return true

	var collision_point = result["position"]
	if raycast_origin.y - collision_point.y > min_fall_height:
		return true

	return false

func reset_patrol_timer():
	patrol_timer = randf_range(patrol_min_time, patrol_max_time)
	is_stopped = randf() < stop_chance
	if not is_stopped:
		choose_new_direction()

func _on_vision_area_body_entered(body):
	if body.is_in_group("Player"):
		target_player = body
		is_chasing = true
		is_stopped = false

func _on_vision_area_body_exited(body):
	if body == target_player:
		target_player = null
		is_chasing = false
		reset_patrol_timer()

func _on_death_area_body_entered(body):
	if body.is_in_group("Player"):
		if not body.is_invincible:  # Verifica o estado de invencibilidade da Libu
			body.take_damage(1)  # Causa 1 de dano
			print("Player tomou dano!")
			


func take_damage(amount: int, knockback_direction: Vector3 = Vector3.ZERO):
	health -= amount
	print("Inimigo recebeu dano:", amount, "| Vida restante:", health)

	# Ativa o estado de dano
	is_hurt = true
	hurt_timer = hurt_duration

	if knockback_direction != Vector3.ZERO:
		apply_knockback(knockback_direction, knockback_force)

	if health <= 0:
		die()


func die():
	print("Inimigo morreu.")
	vision_area.monitoring = false  # Desativa a área de visão
	death_area.monitoring = false  # Desativa a área de morte
	queue_free()

func update_sprite_orientation():
	if sprite and get_viewport().get_camera_3d():
		var camera_position = get_viewport().get_camera_3d().global_transform.origin
		sprite.look_at(camera_position, Vector3.UP)
		sprite.rotation.x = 0
		sprite.rotation.z = 0

func apply_knockback(direction: Vector3, force: float):
	knockback_velocity = direction.normalized() * force
	knockback_timer = knockback_duration
