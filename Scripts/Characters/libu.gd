extends CharacterBody3D

@onready var shoot_origin = $ShootOrigin # Referência ao ponto de disparo
@onready var raycast_wall_front = $WallRayCastFront
@onready var raycast_wall_back = $WallRayCastBack
@onready var raycast_wall_left = $WallRayCastLeft
@onready var raycast_wall_right = $WallRayCastRight
@onready var mesh_instance = $Sprite3D
@onready var life_bar_normal = $"../CanvasLayer/HUD_Life_Full_Libu"
@onready var life_bar_hurt = $"../CanvasLayer/HUD_Life_Hurt_Libu"
@onready var life_bar_dead = $"../CanvasLayer/HUD_Life_Dead_Libu"
@onready var charge_light = $ChargeLight # Referência ao efeito de luz
@onready var shadow_handler = $ShadowHandler
@onready var collision_shape = $LibuShape  # Substitua pelo caminho correto para o CollisionShape3D
@onready var camera = $LibuCamera3D  # Atualize para o caminho correto
# Velocidades

@export var walk_speed: float = 5.0  # Velocidade ao andar normalmente
@export var run_speed: float = 10.0
@export var gravity: float = -20.0
@export var jump_speed: float = 10.0
@export var wall_jump_speed: float = 20.0
@export var wall_jump_upward_speed: float = 15.0
@export var wall_jump_force: float = 15.0  # Força horizontal aplicada no Wall Jump
@export var wall_slide_speed: float = 5.0
@export var dash_cooldown: float = 3.0  # Cooldown do dash (ajustável no editor)
@export var dash_duration: float = 0.3  # Duração do dash
@export var dash_multiplier: float = 2.0  # Multiplicador de velocidade para o dash
@export var wall_jump_horizontal_force: float = 15.0  # Força horizontal aplicada no Wall Jump
@export var wall_jump_upward_force: float = 15.0  # Força vertical aplicada no Wall Jump
@export var wall_jump_max_angle: float = 75.0  # Ângulo máximo para considerar a parede escalável (em graus)
@export var wall_jump_restrict_mode: int = 0  # Modo de restrição do Wall Jump
@export var coyote_time_duration: float = 0.2  # Tempo máximo do Coyote Time em segundos

@export var short_hop_gravity_multiplier: float = 2.0  # Gravidade aumentada para pulo curto
@export var fall_gravity_multiplier: float = 1.2  # Gravidade aumentada durante a queda
@export var umbrella_jump_boost: float = 100.0  # Força do pulo do guarda-chuva

@export var acceleration_time: float = 0.3  # Tempo para acelerar ao correr
@export var deceleration_time: float = 0.3  # Tempo para desacelerar ao soltar o botão de correr
@export var stop_time: float = 0.15  # Tempo para parar completamente ao soltar os direcionais
@export var max_speed: float = 10.0  # Velocidade máxima ao correr
@export var friction_threshold: float = 0.1  # Velocidade mínima antes de parar completamente

@export var dash_speed: float = 20.0  # Velocidade do dash (ajustável no editor)
# Tiro
@export var crosshair_scene: PackedScene
@export var targeting_radius: float = 20.0
@export var crosshair_distance_threshold: float = 0.2
@export var shoot_cooldown: float = 0.5
@export var projectile_scene: PackedScene
@export var max_charge_time: float = 2.0
@export var charged_projectile_scene: PackedScene

# Tempos de estados
@export var stick_time: float = 0.2
@export var slide_time: float = 0.4
@export var input_cooldown: float = 0.4  # Cooldown para cada direcional
@export var dash_input_window: float = 0.2  # Janela de tempo para duplo shift (ajustável no editor)
@export var gentle_fall_speed: float = -2  # Velocidade ao cair suavemente
@export var vertical_jump_boost: float = 15.0  # Força do pulo vertical extra

# Indica se o inventário está aberto
var umbrella_used: bool = false  # Controla o uso do guarda-chuva
var can_glide: bool = false
var jumping_up: bool = false

var is_inventory_open: bool = false
var is_camera_locked: bool = false
var umbrella_active = false
var is_holding_jump = false
var dialog_active: bool = false
var acceleration: float
var deceleration: float
var stop_deceleration: float
var target_speed: float  # Velocidade alvo do personagem
var shooter: Node = null  # Referência ao jogador que disparou o projétil
var has_jumped: bool = false
var is_first_person_active = false
var coyote_timer: float = 0.0  # Temporizador do Coyote Time
var can_coyote_jump: bool = false  # Controle de estado do Coyote Time
var wall_jump_timer: float = 0.4  # Tempo total do Wall Jump
var is_wall_jumping: bool = false  # Nova flag para controlar o estado do Wall Jump
var last_wall_slide_input: Vector3 = Vector3.ZERO  # Direção do input que iniciou o Wall Slide
var charge_time: float = 0.0
var is_charging: bool = false
var current_target: Node = null
var crosshair_instance: Node = null
var max_health = 2
var current_health = 2
var is_invincible = false
var invincibility_time = 1.5  # Tempo em segundos de invencibilidade
var is_dead = false
var current_platform_velocity: Vector3 = Vector3.ZERO
var player_height: float = 0.0  # A altura será calculada dinamicamente
var previous_platform_position: Vector3 = Vector3.ZERO

var dash_timer: float = 0.0  # Temporizador para a duração do dash
var dash_cooldown_timer: float = 0.0  # Temporizador para o cooldown do dash
var is_dashing: bool = false  # Estado do dash
var dash_direction: Vector3 = Vector3.ZERO  # Direção do dash
var dash_input_timer: float = 0.0  # Timer para verificar duplo shift (impulso rápido)
var last_dash_attempt_time: float = 0.0  # Tempo da última tentativa de dash
var last_y_position: float = 0.0  # Armazena a altura inicial do dash

var platform_velocity: Vector3 = Vector3.ZERO
var current_platform: Node = null

var can_dash: bool = true  # Controle de cooldown
var last_dash_attempt: bool = false  # Armazena se o shift foi pressionado antes
var wall_jump_weight = 0.9  # Peso da direção do Wall Jump
var input_weight = 1.0 - wall_jump_weight  # Peso dos inputs

var is_wall_sliding: bool = false
var wall_normal: Vector3 = Vector3.ZERO
var active_raycast: RayCast3D = null
var stick_timer: float = 0.0
var slide_timer: float = 0.0
var input_hold_time: float = 0.0
var in_wall_jump: bool = false  # Controle do estado de Wall Jump
var can_grab_wall: bool = true  # Permite iniciar o ciclo de grude
var time_since_last_shot: float = 0.0  # Cooldown para disparo
# Cooldowns por direção
var input_cooldowns = {
	"front": 0.0,
	"back": 0.0,
	"left": 0.0,
	"right": 0.0
}
# Movimentação
var direction: Vector3 = Vector3.ZERO
var last_direction: Vector3 = Vector3.FORWARD
var input_direction: Vector3 = Vector3.ZERO  # Direção do input do jogador no momento do grude

func _ready():
	$Sprite3D/IteminHand.visible = false  # Item começa invisível
	
	# Calcula taxas de aceleração e desaceleração baseadas no tempo desejado
	acceleration = (run_speed - walk_speed) / acceleration_time
	deceleration = (run_speed - walk_speed) / deceleration_time
	stop_deceleration = walk_speed / stop_time
	calculate_player_height()  # Calcula a altura do jogador ao iniciar
	hide_all_life_bars()
	update_life_bar()  # Mostra a barra inicial correta
	if mesh_instance == null:
		mesh_instance = $Sprite3D

	# Inicializa a barra de vida e HUD
	update_life_bar()

	# Instancia o crosshair
	if crosshair_scene:
		crosshair_instance = crosshair_scene.instantiate()
		get_tree().current_scene.add_child.call_deferred(crosshair_instance)
		crosshair_instance.visible = false
	else:
		print("Debug: crosshair_scene não atribuído.")

	for platform in get_tree().get_nodes_in_group("MovingPlatform"):
		platform.connect("player_entered", Callable(self, "_on_platform_entered"))
		platform.connect("player_exited", Callable(self, "_on_platform_exited"))
		
	if camera:
		camera.connect("first_person_toggled", Callable(self, "_on_first_person_toggled"))

func _input(event):
	if is_camera_locked:
		print("Câmera bloqueada.")
		return
	if is_inventory_open:
		return  # Bloqueia inputs enquanto o inventário está aberto
	if is_dead:
		return  # Ignora qualquer input se estiver morto
		
	if dialog_active:
		# Bloqueia a rotação da câmera
		return

	# **Wall Jump**
	if event.is_action_pressed("ui_accept") and is_wall_sliding:
		perform_wall_jump()

	# **Dash - Ativado apenas com Duplo Shift**
	if event.is_action_pressed("ui_run"):  # Shift pressionado
		var current_time = Time.get_ticks_msec() / 1000.0  # Tempo atual em segundos

		if last_dash_attempt_time > 0 and (current_time - last_dash_attempt_time) < dash_input_window:
			# Se o tempo entre os dois pressionamentos for menor que o permitido, ativa o dash
			start_dash()
		else:
			# Se for o primeiro Shift pressionado, apenas armazena o tempo
			last_dash_attempt_time = current_time

	# **Mira no inimigo**
	if event.is_action_pressed("ui_attack2"):  # Botão direito do mouse
		find_target()
	elif event.is_action_released("ui_attack2"):
		clear_target()  # Remove o alvo e a mira

	# **Carregamento e Disparo**
	if event.is_action_pressed("ui_attack"):  # Botão de ataque pressionado
		if not is_charging:  # Inicia o carregamento
			is_charging = true
			charge_time = 0.0
			charge_light.visible = true  # Ativa o efeito de luz
	elif event.is_action_released("ui_attack"):  # Botão de ataque solto
		if is_charging:  # Verifica se estava carregando
			if charge_time >= max_charge_time:
				shoot_charged_projectile()  # Dispara o projétil carregado
			else:
				shoot_projectile()  # Dispara o projétil normal
			charge_light.visible = false  # Desativa o efeito de luz
			is_charging = false  # Reseta o estado de carregamento

	# **Mecânica do Guarda-chuva**
	if umbrella_active:
		if event.is_action_pressed("ui_accept") and not is_on_floor() and not umbrella_used:
			is_holding_jump = true
			print("☂️ Queda suave ativada com guarda-chuva!")
		elif event.is_action_released("ui_accept"):
			is_holding_jump = false
			print("🛑 Queda suave desativada!")

		# Adiciona impulso especial ao pular com o guarda-chuva
		if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and not umbrella_used:
			velocity.y = umbrella_jump_boost
			umbrella_used = true  # Marca que o guarda-chuva foi usado
			print("☂️ Pulo especial ativado! Velocidade Y:", velocity.y)

func _process(delta):

	_update_sprite_orientation()
	handle_crosshair(delta)
	if is_inventory_open:
		return  # Bloqueia qualquer input enquanto o inventário está aberto
	if dash_input_timer > 0:
		dash_input_timer -= delta  # Diminui o tempo da janela de duplo shift
		
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if is_dead:
		return  # Ignora o processamento se estiver morto

	# Atualiza a posição e visibilidade da mira enquanto o botão está pressionado
	if Input.is_action_pressed("ui_attack2") and current_target:
		if current_target and current_target.is_inside_tree():
			# Atualiza a posição da mira no inimigo
			crosshair_instance.global_transform.origin = current_target.global_transform.origin
		else:
			clear_target()  # Remove o alvo e a mira se não for mais válido

	# Desativa a mira se o inimigo sair do raio de alcance
	if current_target and global_transform.origin.distance_to(current_target.global_transform.origin) > targeting_radius:
		clear_target()
	# Atualiza os cooldowns por direção
	for key in input_cooldowns.keys():
		if input_cooldowns[key] > 0:
			input_cooldowns[key] -= delta
	# Atualiza o cooldown do disparo
	if time_since_last_shot > 0:
		time_since_last_shot -= delta
		
	if is_charging:
		charge_time += delta
		charge_light.light_energy = lerp(0, 4, charge_time / max_charge_time)  # Aumenta a intensidade
		charge_light.omni_range = lerp(5, 20, charge_time / max_charge_time)  # Aumenta o alcance
  # Aumenta o alcance
		if charge_time >= max_charge_time:
			charge_time = max_charge_time  # Limita o tempo de carga

func calculate_player_height():
	# Verifica se o CollisionShape está configurado
	if collision_shape and collision_shape.shape:
		var shape = collision_shape.shape
		if shape is BoxShape3D:
			player_height = shape.extents.y * 2  # Altura do BoxShape é o dobro do extents.y
			print("Altura do jogador detectada (BoxShape3D):", player_height)
		elif shape is CapsuleShape3D:
			player_height = shape.height + (shape.radius * 2)  # Altura + diâmetro da cápsula
			print("Altura do jogador detectada (CapsuleShape3D):", player_height)
		else:
			print("Tipo de shape não suportado:", shape)
	else:
		player_height = 2.0  # Valor padrão caso não seja possível calcular
		print("Usando altura padrão:", player_height)
func find_target():
	var nearby_enemies = []

	# Verifica inimigos no raio de alcance
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy and enemy.is_inside_tree():
			var distance = global_transform.origin.distance_to(enemy.global_transform.origin)
			if distance <= targeting_radius:
				nearby_enemies.append(enemy)

	# **Se não há inimigos, oculta a mira e sai da função**
	if nearby_enemies.is_empty():
		clear_target()
		return

	# Escolhe o inimigo mais próximo
	var closest_enemy = null
	var smallest_distance = targeting_radius
	for enemy in nearby_enemies:
		var distance = global_transform.origin.distance_to(enemy.global_transform.origin)
		if distance < smallest_distance:
			smallest_distance = distance
			closest_enemy = enemy

	if closest_enemy:
		current_target = closest_enemy

		# Verifica se a instância do crosshair é válida antes de ativá-la
		if is_instance_valid(crosshair_instance):
			crosshair_instance.visible = true
			crosshair_instance.global_transform.origin = current_target.global_transform.origin
			print("Alvo selecionado:", closest_enemy.name)
		else:
			print("crosshair_instance não é válido!")
	else:
		clear_target()

func update_life_bar():
	hide_all_life_bars()  # Oculta todas as barras antes de exibir a correta

	if current_health == 2:
		if life_bar_normal:
			life_bar_normal.visible = true
	elif current_health == 1:
		if life_bar_hurt:
			life_bar_hurt.visible = true
	elif current_health <= 0:
		if life_bar_dead:
			life_bar_dead.visible = true
	else:
		print("Erro: Estado de vida desconhecido.")
	
func take_damage(amount: int):
	if is_dead or is_invincible:
		print("Dano ignorado - Morta ou Invencível")
		return  # Não toma dano se estiver morta ou invencível

	print("Recebendo dano:", amount)
	current_health -= amount  # Reduz a vida
	update_life_bar()  # Atualiza a HUD

	if current_health > 0:
		is_invincible = true
		print("Libu está invencível por", invincibility_time, "segundos")
		await get_tree().create_timer(invincibility_time).timeout
		is_invincible = false
		print("Libu não está mais invencível")
	else:
		die()

	# No final da função take_damage
	get_parent().get_node("Character Switch").update_hud(self)

func die():
	is_dead = true
	update_life_bar()
	print("Libu morreu!")

	if crosshair_instance:
		crosshair_instance.visible = false  # Desativa o crosshair

	# Pausa para mostrar o estado de morte
	await get_tree().create_timer(2).timeout

	# Reinicia o nível ou os estados (ajuste conforme necessário)
	current_health = max_health
	is_dead = false
	is_invincible = false
	print("Reiniciando a cena")
	get_tree().reload_current_scene()  # Reinicia o nível

func handle_crosshair(_delta):
	if current_target:
		if not is_instance_valid(current_target):  # Verifica se o nó ainda é válido
			current_target = null  # Limpa a referência se o nó não for mais válido
			crosshair_instance.visible = false
			return

		if current_target.is_inside_tree():  # Agora é seguro chamar is_inside_tree()
			crosshair_instance.global_transform.origin = current_target.global_transform.origin
			crosshair_instance.visible = true
		else:
			if crosshair_instance:
				crosshair_instance.visible = false
	else:
		if crosshair_instance:
			crosshair_instance.visible = false

func clear_target():
	current_target = null
	
	# Garante que a mira desapareça se não houver um alvo válido
	if is_instance_valid(crosshair_instance):
		crosshair_instance.visible = false
		# Define a posição da mira para um local seguro (fora da tela ou no centro da câmera)
		crosshair_instance.global_transform.origin = Vector3.ZERO  
		print("Mira desativada.")
	else:
		print("crosshair_instance já foi liberado.")

func _physics_process(delta):
	if is_inventory_open:
		velocity = Vector3.ZERO  # Garante que o personagem não se mova
		return  # Bloqueia movimentação enquanto o inventário está aberto

	if dialog_active or is_dead:
		return  # Bloqueia a movimentação se estiver em diálogo ou morto

	# Impede Double Jump total
	if has_jumped and not is_on_floor():
		can_coyote_jump = false

	# 1) Aplicar gravidade com modificadores
	if not is_on_floor():
		# 🔥 Permite ativar o glide a qualquer momento no ar
		if Input.is_action_just_pressed("ui_accept") and umbrella_active:
			is_holding_jump = true  # Ativa o glide
			umbrella_used = true  # O guarda-chuva foi usado, mas pode ser reativado
			print("☂️ Glide ativado!")

		if Input.is_action_just_released("ui_accept"):
			is_holding_jump = false  # Permite desativar o glide e voltar à queda livre
			print("🛑 Glide desativado!")

		if umbrella_active and is_holding_jump:
			# Queda suave com o guarda-chuva
			velocity.y = lerp(velocity.y, gentle_fall_speed, 0.05)
		else:
			# Gravidade normal (queda livre)
			if velocity.y > 0 and not Input.is_action_pressed("ui_accept"):
				# Pulo curto: jogador soltou o botão de pulo
				velocity.y += gravity * short_hop_gravity_multiplier * delta
			elif velocity.y < 0:
				# Queda acelerada: jogador está caindo
				velocity.y += gravity * fall_gravity_multiplier * delta
			else:
				# Gravidade padrão
				velocity.y += gravity * delta

		# Inicia o Coyote Time se não tiver pulado
		if not has_jumped:
			coyote_timer += delta
			if coyote_timer < coyote_time_duration:
				can_coyote_jump = true
			else:
				can_coyote_jump = false
	else:
		# 🔥 Reseta estados ao tocar o chão
		coyote_timer = 0.0
		can_coyote_jump = false
		has_jumped = false  # Permite novo pulo após tocar o chão
		umbrella_used = false  # Libera o uso do guarda-chuva novamente
		is_holding_jump = false  # Reseta a queda suave

	# 2) Verifica se estamos no meio de um Wall Jump
	if is_wall_jumping:
		wall_jump_timer -= delta
		if wall_jump_timer > 0:
			velocity.y += gravity * delta  # Continua aplicando gravidade
			move_and_slide()
			return
		else:
			is_wall_jumping = false

	# 3) Executa o dash se estiver ativo
	if is_dashing:
		perform_dash(delta)
		return

	# 4) Atualiza cooldown do dash
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# 5) Reseta estados de Wall Slide se estiver no chão
	if is_on_floor():
		reset_wall_slide()
		can_grab_wall = true
		has_jumped = false
		can_coyote_jump = false  # Evita ativação indevida do Coyote Time
		coyote_timer = 0.0  # Reseta o timer de Coyote Time

	# 6) Atualiza Wall Slide
	if not is_wall_jumping:
		update_wall_slide(delta)

	# 7) Executa lógica de Wall Slide
	if is_wall_sliding:
		handle_wall_slide(delta)
	else:
		# 8) Movimentação horizontal
		_handle_input(delta)

	# 9) Executa pulo normal e bloqueia double jump
# 9) Executa pulo normal e bloqueia double jump
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			# 🔥 Pulo normal
			velocity.y = jump_speed
			has_jumped = true
			can_coyote_jump = false  # Impede uso do Coyote Time depois do pulo
			coyote_timer = -1.0  # Reseta o timer
		elif can_coyote_jump and not has_jumped:
			# 🔥 Pulo Coyote Time permitido APENAS se não tiver pulado antes
			velocity.y = jump_speed
			has_jumped = true
			can_coyote_jump = false  # Bloqueia outro pulo pelo Coyote Time
			coyote_timer = -1.0

	if velocity.y < 0:  
		jumping_up = false  # 🔥 Permite outro pulo somente após atingir o ápice

		# 🔥 Se estiver sobre uma plataforma, herda sua velocidade
	# 🔥 Se estiver sobre uma plataforma, ajusta a velocidade corretamente
	# 🔥 Se estiver sobre uma plataforma, ajusta a velocidade corretamente
	if current_platform:
		# Adiciona a velocidade da plataforma ao personagem
		velocity += current_platform.velocity
		
		# Move o personagem com a nova velocidade
		move_and_slide()
		
		# Remove a velocidade da plataforma após o movimento
		velocity -= current_platform.velocity  
	else:
		# Se não estiver sobre uma plataforma, reduz pequenos valores residuais
		if abs(velocity.x) < 0.01:
			velocity.x = 0
		if abs(velocity.z) < 0.01:
			velocity.z = 0
		
		# Move normalmente sem a velocidade da plataforma
		move_and_slide()



func _debug_wall_normal():
	if active_raycast and active_raycast.is_colliding():
		var collision_point = active_raycast.get_collision_point()
		@warning_ignore("shadowed_variable")
		var wall_normal = active_raycast.get_collision_normal()

		# Desenha a normal da parede
		get_viewport().debug_draw_line(collision_point, collision_point + wall_normal * 2.0, Color(1, 0, 0))

func reset_wall_slide():
	is_wall_sliding = false
	active_raycast = null
	stick_timer = 0.0
	slide_timer = 0.0
	input_hold_time = 0.0
	input_direction = Vector3.ZERO

	# Se o modo exige tocar o chão, libera novamente o Wall Jump
	if wall_jump_restrict_mode == 2:
		can_grab_wall = true

func update_wall_slide(delta):
	if is_wall_sliding or not can_grab_wall:
		return

	active_raycast = null

	for raycast in [raycast_wall_front, raycast_wall_back, raycast_wall_left, raycast_wall_right]:
		raycast.enabled = true
		if raycast.is_colliding():
			wall_normal = raycast.get_collision_normal()
			#print("Normal da parede: ", wall_normal)  # Debug para verificar a normal da parede
			var input_towards_wall = wall_normal.dot(direction.normalized()) < 0.1

			var raycast_direction = get_raycast_direction(raycast)

			if input_towards_wall and input_cooldowns[raycast_direction] <= 0 and not is_on_floor():
				input_hold_time += delta
				if input_hold_time >= stick_time:
					print("Início do Wall Slide!")  # Debug para verificar o início do deslize
					is_wall_sliding = true
					active_raycast = raycast
					input_direction = direction.normalized()  # Armazena a direção do input
					last_wall_slide_input = input_direction  # Salva o input que iniciou o deslize
					stick_timer = stick_time
					slide_timer = slide_time
					velocity = Vector3.ZERO
					can_grab_wall = false
					input_cooldowns[raycast_direction] = input_cooldown
					return
			else:
				input_hold_time = 0.0

func handle_wall_slide(delta):
	if stick_timer > 0:
		stick_timer -= delta
		velocity = Vector3.ZERO
	elif slide_timer > 0:
		slide_timer -= delta
		velocity.y = max(-wall_slide_speed, velocity.y)
	else:
		reset_wall_slide()

func get_raycast_direction(raycast):
	if raycast == raycast_wall_front:
		return "front"
	elif raycast == raycast_wall_back:
		return "back"
	elif raycast == raycast_wall_left:
		return "left"
	elif raycast == raycast_wall_right:
		return "right"
	return ""

func perform_wall_jump():
	if is_wall_sliding:
		print("Wall Jump executado!")
		is_wall_sliding = false
		is_wall_jumping = true
		wall_jump_timer = 0.2  # Tempo do Wall Jump

		# Obtém a normal da parede usando o RayCast ativo
		if active_raycast and active_raycast.is_colliding():
			@warning_ignore("shadowed_variable")
			var wall_normal = active_raycast.get_collision_normal()
			print("Normal da parede: ", wall_normal)

			# Impulso horizontal afastando o jogador da parede
			var horizontal_impulse = wall_normal
			horizontal_impulse.y = 0  # Remove a componente vertical
			horizontal_impulse = horizontal_impulse.normalized() * wall_jump_horizontal_force

			# Aplica os impulsos horizontal e vertical (oposto à parede)
			velocity = Vector3.ZERO
			velocity -= horizontal_impulse  # Subtrai para garantir que vai na direção oposta
			velocity.y = wall_jump_upward_force

			print("Impulso horizontal aplicado (X, Z): ", horizontal_impulse.x, horizontal_impulse.z)
			print("Velocidade aplicada (X, Y, Z): ", velocity)

			# Aplica a restrição baseada na configuração
			if wall_jump_restrict_mode == 0:  # 🔄 Agora 0 significa "Troca de Parede Obrigatória"
				can_grab_wall = false
				await get_tree().create_timer(0.2).timeout  # Pequeno delay antes de permitir nova parede
				can_grab_wall = true

			elif wall_jump_restrict_mode == 2:  # 🔄 2 ainda é "Tocar o Chão Primeiro"
				can_grab_wall = false  # Só poderá se grudar na parede de novo ao tocar o chão

		else:
			print("RayCast não detectou uma parede!")

		await get_tree().create_timer(wall_jump_timer).timeout
		is_wall_jumping = false  # Finaliza o estado de Wall Jump

@onready var shoot_ray = $LibuCamera3D/RayCast3D  # Referência ao RayCast3D dentro da câmera

func shoot_projectile():
	if time_since_last_shot > 0:
		return  # Respeita o cooldown de disparo

	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)

		if is_first_person_active:
			var camera = get_viewport().get_camera_3d()
			if camera:
				# Origem do tiro: um pouco à frente da câmera
				projectile.global_transform.origin = camera.global_transform.origin + camera.global_transform.basis.z * -1.5
				
				# **Se há um alvo, o projétil segue ele**
				if current_target and current_target.is_inside_tree():
					projectile.set_target(current_target)  # 🔥 Torna o tiro teleguiado
				else:
					# Direção da câmera caso não tenha alvo
					var shoot_direction = -camera.global_transform.basis.z.normalized()
					projectile.set_velocity(shoot_direction)
		else:
			# Caso não esteja em primeira pessoa, usa a lógica padrão
			projectile.global_transform.origin = shoot_origin.global_transform.origin

			if current_target and current_target.is_inside_tree():
				projectile.set_target(current_target)  # 🔥 Mantém o alvo para seguir!
			else:
				var shoot_direction = last_direction
				shoot_direction.y = 0
				shoot_direction = shoot_direction.normalized()
				projectile.set_velocity(shoot_direction)

		# Configurações do projétil
		projectile.damage = 1
		projectile.scale = Vector3(1, 1, 1)

		# Ignora colisões com o jogador
		if projectile.has_method("add_exception"):
			projectile.add_exception(self)

		# Reseta o cooldown
		time_since_last_shot = shoot_cooldown
		print("Projétil disparado.")
	else:
		print("Debug: Cena de projétil não configurada!")

func _on_projectile_body_entered(body):
	if body.name == "HikaruEvil":  # Verifica se o objeto atingido é o Hikaru
		body.take_damage()
		
func _on_projectile_collided(body):
	if body.is_in_group("Wall"):  # Verifica se colidiu com uma parede
		print("Projétil colidiu com uma parede!")
		body.queue_free()  # Remove o projétil
	elif body.is_in_group("Enemy"):  # Colisão com inimigo
		print("Projétil atingiu um inimigo!")
		if body.has_method("take_damage"):
			body.take_damage(1)  # Aplica dano ao inimigo (ajuste o valor se necessário)
		body.queue_free()  # Remove o projétil

func _update_sprite_orientation():
	if mesh_instance and mesh_instance.is_inside_tree():
		var camera = get_viewport().get_camera_3d()
		if camera:
			var camera_position = camera.global_transform.origin
			mesh_instance.look_at(camera_position, Vector3.UP)
			mesh_instance.rotation.x = 0
			mesh_instance.rotation.z = 0

@warning_ignore("unused_parameter")
func _handle_input(delta):
	# 1) Captura o input direcional (WASD ou setas)
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("ui_down"):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_up"):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1

	# 2) Ajusta direção com base na câmera
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		var camera_transform = get_viewport().get_camera_3d().global_transform
		var forward = -camera_transform.basis.z.normalized()
		var right = camera_transform.basis.x.normalized()

		# Ajusta direção do movimento com base na câmera
		var final_dir = (forward * input_dir.z) + (right * input_dir.x)
		final_dir = final_dir.normalized()

		# 3) Ajusta a velocidade com aceleração progressiva
		if Input.is_action_pressed("ui_run"):
			# Aceleração para corrida
			target_speed = min(target_speed + acceleration * delta, run_speed)
		else:
			# Retorna para velocidade normal ao andar
			target_speed = max(target_speed - deceleration * delta, walk_speed)

		velocity.x = final_dir.x * target_speed
		velocity.z = final_dir.z * target_speed

		# Atualiza última direção
		last_direction = final_dir
	else:
		# 4) Desaceleração natural ao soltar os direcionais
		if velocity.length() > 0.1:
			velocity.x = lerp(velocity.x, 0.0, stop_deceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, stop_deceleration * delta)

			# Evita deslizar indefinidamente
			if absf(velocity.x) < 0.1:
				velocity.x = 0.0
			if absf(velocity.z) < 0.1:
				velocity.z = 0.0
		else:
			velocity = Vector3.ZERO

	# 5) Pulo normal se estiver no chão
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_speed
		
	if is_on_floor():
		umbrella_used = false  # Libera o uso do guarda-chuva novamente
		is_holding_jump = false  # Garante que a queda suave está desativada



func shoot_charged_projectile():
	if time_since_last_shot > 0:
		return  # Respeita o cooldown de disparo

	if charged_projectile_scene:
		var projectile = charged_projectile_scene.instantiate()

		# Define a origem do tiro dependendo do modo de visão
		if is_first_person_active:
			var camera = get_viewport().get_camera_3d()
			if camera:
				projectile.global_transform.origin = camera.global_transform.origin + camera.global_transform.basis.z * -1.5
				
				# **Se há um alvo, o projétil segue ele**
				if current_target and current_target.is_inside_tree():
					projectile.set_target(current_target)  # 🔥 Torna o tiro teleguiado
				else:
					# Direção da câmera caso não tenha alvo
					var shoot_direction = -camera.global_transform.basis.z.normalized()
					projectile.set_velocity(shoot_direction)
		else:
			# Caso não esteja em primeira pessoa, usa a lógica padrão
			projectile.global_transform.origin = shoot_origin.global_transform.origin

			if current_target and current_target.is_inside_tree():
				projectile.set_target(current_target)  # 🔥 Mantém o alvo para seguir!
			else:
				var shoot_direction = last_direction
				shoot_direction.y = 0
				shoot_direction = shoot_direction.normalized()
				projectile.set_velocity(shoot_direction)

		# Configurações do projétil carregado
		projectile.damage = 5
		projectile.scale = Vector3(1.4, 1.4, 1.4)

		# Adiciona o projétil à cena
		get_parent().add_child(projectile)

		# Reseta cooldown e tempo de carga
		time_since_last_shot = shoot_cooldown
		charge_time = 0.0
		charge_light.visible = false  # Desativa o efeito de luz
	else:
		print("Debug: Cena de projétil carregado não configurada!")

func _on_platform_entered(platform):
	current_platform = platform
	previous_platform_position = platform.global_transform.origin

func _on_platform_exited(platform):
	if current_platform == platform:
		current_platform = null

# Função que executa o dash
func perform_dash(delta):
	if dash_timer > 0:
		dash_timer -= delta

		# **🔥 Mantém a posição vertical original**
		var new_position = global_transform.origin
		new_position.y = last_y_position  # 🔥 Mantém a altura do início do dash
		global_transform.origin = new_position

		# **🔥 Mantém a velocidade do dash na horizontal**
		velocity = dash_direction * dash_speed

		move_and_slide()
	else:
		print("🏁 Dash finalizado!")
		is_dashing = false  # Termina o dash
		
		# **🔥 Evita queda brusca aplicando uma gravidade suave**
		velocity.y = -2.0  # Reduz o impacto da queda logo após o dash

func start_dash():
	if is_dashing or dash_cooldown_timer > 0:
		return  # Não permite iniciar o dash se já estiver ativo ou em cooldown

	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown  # Reinicia cooldown corretamente
	last_dash_attempt_time = 0  # Reseta o tempo do duplo Shift para evitar múltiplos dashes

	# **Se o jogador não estiver apertando direcional, mantém a última direção**
	if direction.length() > 0:
		dash_direction = direction.normalized()
	else:
		dash_direction = last_direction.normalized()

	# **🔥 Mantém a altura inicial do dash**
	last_y_position = global_transform.origin.y

	# **🔥 Mantém a velocidade horizontal**
	velocity = dash_direction * dash_speed
	velocity.y = 0  # 🔥 Impede que o dash tenha impacto vertical

	print("🔥 Dash iniciado! Direção:", dash_direction, "Velocidade:", velocity, "Altura mantida:", last_y_position)
func _on_first_person_toggled(active):
	is_first_person_active = active
		
		
func heal(amount):
	if current_health < max_health:  # Garante que não passe do máximo
		current_health += amount
		if current_health > max_health:
			current_health = max_health
		print("Curado! Vida atual: ", current_health)
		update_life_bar()  # Atualiza a interface da vida
		
func reset_shooting_state():
	# Reseta estados relacionados ao disparo
	is_charging = false
	charge_time = 0.0
	time_since_last_shot = shoot_cooldown  # Garante que o cooldown está no estado inicial
	if charge_light:
		charge_light.visible = false  # Esconde a luz de carregamento
	if crosshair_instance:
		crosshair_instance.visible = false  # Esconde a mira, se existir
	current_target = null  # Remove qualquer alvo
	print("Estado de disparo resetado.")

	
func disconnect_events():
	# Desconecta sinais conectados dinamicamente
	if is_connected("timeout", Callable(self, "_on_timeout")):
		disconnect("timeout", Callable(self, "_on_timeout"))
		
func disable_combat():
	# Desativa combate
	is_charging = false
	time_since_last_shot = 0.0
	charge_time = 0.0
	if charge_light:
		charge_light.visible = false  # Esconde a luz de carregamento
	if crosshair_instance:
		crosshair_instance.visible = false  # Esconde o crosshair
		crosshair_instance.queue_free()  # Remove a mira da cena para evitar duplicações
	current_target = null  # Remove o alvo atual
	print(self.name, "combate desativado.")

func enable_combat():
	# Reativa combate
	if crosshair_scene and not crosshair_instance:
		crosshair_instance = crosshair_scene.instantiate()
		get_tree().current_scene.add_child(crosshair_instance)
		crosshair_instance.visible = false  # Começa escondido
	print(self.name, "combate ativado.")
	
func hide_all_life_bars():
	if life_bar_normal:
		life_bar_normal.visible = false
	if life_bar_hurt:
		life_bar_hurt.visible = false
	if life_bar_dead:
		life_bar_dead.visible = false
		
func show_all_life_bars():
	update_life_bar()  # Garante que apenas a barra correspondente ao estado atual seja exibida
	
func set_inventory_lock(lock: bool):
	is_inventory_open = lock  # Atualiza o estado de bloqueio
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if lock else Input.MOUSE_MODE_CAPTURED
	if lock:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Mostra o cursor
		print(self.name, "bloqueado.")
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Captura o cursor
		print(self.name, "desbloqueado.")

func update_sprite_orientation():
	var camera = get_viewport().get_camera_3d()
	if camera:
		$Sprite3D.look_at(camera.global_transform.origin, Vector3.UP)

func set_dialog_active(state: bool):
	dialog_active = state
	

func equip_item(item_texture: Texture):
	if item_texture != null:
		var sprite = $Sprite3D/IteminHand
		if sprite:
			sprite.texture = item_texture  # Aplica a textura ao Sprite3D
			sprite.visible = true  # Torna o Sprite3D visível

			# Ativa o guarda-chuva se for a textura correspondente
			if item_texture == preload("res://Sprites/Inventory/UmbrellaBIG.png"):  # Substitua pelo caminho correto
				set_umbrella_active(true)
			else:
				set_umbrella_active(false)
		else:
			print("⚠️ Sprite3D não encontrado no caminho especificado.")
	else:
		var sprite = $Sprite3D/IteminHand
		if sprite:
			sprite.texture = null  # Remove a textura
			sprite.visible = false  # Torna o Sprite3D invisível
			set_umbrella_active(false)

			
func use_inventory_item(index: int):
	get_node("$../CanvasLayer").use_item(index, self)  # Substitua "Inventario" pelo caminho correto
	
func set_umbrella_active(active: bool):
	umbrella_active = active
	#print("☂️ Guarda-chuva status atualizado:", active)

	if not active:
		is_holding_jump = false  # Reseta a queda suave se o guarda-chuva for removido
		#print("🛑 Guarda-chuva desativado.")
	#else:
		#print("✅ Guarda-chuva ativado!")
