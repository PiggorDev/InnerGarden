extends CharacterBody3D

@onready var health_manager = "res://Scripts/System/HealthManager.gd"
@onready var shoot_origin = $ShootOrigin # Referência ao ponto de disparo
@onready var raycast_wall_front = $WallRayCastFront
@onready var raycast_wall_back = $WallRayCastBack
@onready var raycast_wall_left = $WallRayCastLeft
@onready var raycast_wall_right = $WallRayCastRight
@onready var mesh_instance = $Sprite3D
@onready var punch_effect = $PunchEffect # Substitua pelo caminho correto do nó na cena
@onready var punch_light = $PunchLight # Substitua pelo caminho correto do nó de luz
@onready var charge_light = $ChargeLight # Referência ao efeito de luz
@onready var shadow_handler = $ShadowHandler
@onready var collision_shape = $VanessaShape  # Substitua pelo caminho correto para o CollisionShape3D
@onready var camera = $VanessaCamera3D  # Atualize para o caminho correto
@onready var life_bar_full = $"../CanvasLayer/HUD_Life_Full_Soul"  # Vida cheia

@onready var life_bar_dead = $"../CanvasLayer/HUD_Life_Dead_Soul"  # Morta
@onready var punch_aoe = $PunchAOE

# Velocidades
@export var step_height: float = 1.0  # Altura máxima do obstáculo para subir automaticamente
@export var step_check_distance: float = 0.5  # Distância horizontal para verificar o step offset
@export var speed: float = 5.0
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
@export var punch_explosion_scene: PackedScene  # Configure a cena do efeito no editor

@export var short_hop_gravity_multiplier: float = 2.0  # Gravidade aumentada para pulo curto
@export var fall_gravity_multiplier: float = 1.5  # Gravidade aumentada durante a queda


@export var dash_speed: float = 20.0  # Velocidade do dash (ajustável no editor)

# Tiro
@export var crosshair_scene: PackedScene
@export var targeting_radius: float = 20.0
@export var crosshair_distance_threshold: float = 0.2
@export var shoot_cooldown: float = 0.5
@export var projectile_scene: PackedScene
@export var max_charge_time: float = 2.0
@export var charged_projectile_scene: PackedScene


@export var projectile_enabled: bool = true  # Se true, Vanessa atira; se false, ela soca.
@export var punch_distance: float = 1.0              # Distância do avanço no 1º e 2º soco
@export var punch_distance_third: float = 1.5        # Distância de avanço no 3º soco
@export var punch_explosion_radius: float = 2.0      # Raio da explosão nos 1º e 2º socos
@export var punch_explosion_radius_third: float = 3.0  # Raio da explosão no 3º soco
@export var punch_damage: int = 1                    # Dano aplicado a cada inimigo atingido pelo soco

# Tempos de estados
@export var stick_time: float = 0.2
@export var slide_time: float = 0.4
@export var input_cooldown: float = 0.4  # Cooldown para cada direcional
@export var dash_input_window: float = 0.2  # Janela de tempo para duplo shift (ajustável no editor)

@export var throw_radius: float = 5.0        # Raio para buscar inimigos para lançar
@export var throw_up_force: float = 10.0     # Força para lançar inimigos para cima
@export var slam_damage: int = 5             # Dano ao esbater os inimigos no chão
@export var slam_down_force: float = 20.0    # Força para fazer Vanessa descer e “esmagar”
var thrown_enemies: Array = []

# Nova variável para controlar a duração do Wall Jump
# Controle dos socos
# Controle do lançamento de inimigos com botão direito
var punch_velocity: Vector3 = Vector3.ZERO  # Velocidade do avanço do soco
var punch_duration: float = 0.2  # Duração do avanço do soco
var punch_timer_active: float = 0.0  # Temporizador para o avanço do soco

var throw_enemies_state: int = 0  # 0 = inativo, 1 = inimigos lançados para cima aguardando slam
var throw_timer: float = 0.0      # Timer para detectar o clique duplo (0.2s)
var punch_count: int = 0         # Conta quantos socos foram aplicados no combo atual (1 a 3)
var punch_cooldown_timer: float = 2.5  # Cooldown de 0.5s após o terceiro soco
var punch_timer: float = 0.0     # Timer para resetar o combo caso haja pausa entre socos
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
var is_invincible = false
var invincibility_time = 1.5  # Tempo em segundos de invencibilidade
var is_dead = false
var current_platform_velocity: Vector3 = Vector3.ZERO
var player_height: float = 0.0  # A altura será calculada dinamicamente
#var player_bottom = global_transform.origin.y - (player_height / 2)

# Combina a direção do Wall Jump com os inputs ativos

var dash_timer: float = 0.0  # Temporizador para a duração do dash
var dash_cooldown_timer: float = 0.0  # Temporizador para o cooldown do dash
var is_dashing: bool = false  # Estado do dash
var dash_direction: Vector3 = Vector3.ZERO  # Direção do dash
var dash_input_timer: float = 0.0  # Timer para verificar duplo shift (impulso rápido)

var platform_velocity: Vector3 = Vector3.ZERO
var current_platform: Node = null
# Controle de estados

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

var max_health = 4  # Máximo de vida da Vanessa
var current_health = 4  # Vida inicial

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
	
	if punch_effect:
		punch_effect.visible = false

	if punch_light:
		punch_light.visible = false
	# Configurações iniciais
	if charge_light:
		charge_light.visible = false  # Garante que a luz começa invisível
		charge_light.light_energy = 0  # Reduz energia ao mínimo inicial
		charge_light.omni_range = 0   # Reduz alcance ao mínimo inicial

	print("Projectile Enabled: ", projectile_enabled)  # Confirmação do estado inicial

	calculate_player_height()  # Calcula a altura do jogador ao iniciar
	if mesh_instance == null:
		mesh_instance = $Sprite3D

	# Inicializa a barra de vida e HUD
	#update_life_bar()

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
	if event.is_action_pressed("ui_attack2"):
		if projectile_enabled:
			find_target()
		else:
			# Chama as funções de lançamento/esmagar
			if throw_enemies_state == 0:
				perform_enemy_throw()
			elif throw_enemies_state == 1 and throw_timer > 0:
				perform_enemy_slam()
	elif event.is_action_released("ui_attack2"):
		if projectile_enabled:
			clear_target()

	
	if event.is_action_pressed("ui_jump") and is_wall_sliding:
		perform_wall_jump()
		

	
	if is_dead:
		return  # Ignora qualquer input se estiver morto

	 # Botão esquerdo (ui_attack): antes era para tiros; agora será para socos se projectile_enabled for false.
	if event.is_action_pressed("ui_attack"):
		if projectile_enabled:
			if not is_charging:
				is_charging = true
				charge_time = 0.0
				charge_light.visible = true
		else:
			perform_punch()
		
	if event.is_action_released("ui_attack"):
		if projectile_enabled and is_charging:
			if charge_time >= max_charge_time:
				shoot_charged_projectile()
			else:
				shoot_projectile()
			charge_light.visible = false
			is_charging = false

	# Botão direito (ui_attack2): no modo projéteis, a função de mira permanece; no modo soco, faz o lançamento/esmagar.
	if event.is_action_pressed("ui_attack2"):
		if projectile_enabled:
			find_target()
		else:
			# Chama as funções de lançamento/esmagar (veja abaixo)
			if throw_enemies_state == 0:
				perform_enemy_throw()
			elif throw_enemies_state == 1 and throw_timer > 0:
				perform_enemy_slam()
	elif event.is_action_released("ui_attack2"):
		if projectile_enabled:
			clear_target()
	# Detecta o Shift pressionado
	if event.is_action_pressed("ui_run"):
		if dash_input_timer > 0 and dash_cooldown_timer <= 0 and direction.length() > 0:
			# Ativa o dash somente se estiver dentro do tempo e correndo
			start_dash()

	# Detecta o Shift solto
	elif event.is_action_released("ui_run"):
		if direction.length() > 0:  # Garante que o jogador está correndo
			dash_input_timer = dash_input_window  # Inicia a janela de tempo para o segundo Shift


	if is_dead:
		return  # Ignora qualquer input se estiver morto

	# Dash - Verifica o Shift (correr)
	if event.is_action_pressed("ui_run"):  # Detecta o Shift pressionado
		if dash_input_timer > 0 and dash_cooldown_timer <= 0 and direction.length() > 0:  
			# Verifica se o jogador já está correndo
			start_dash()  # Inicia o dash
		else:
			dash_input_timer = dash_input_window  # Define o tempo limite para o duplo Shift
	elif event.is_action_released("ui_run"):  # Reseta o estado ao soltar o Shift
		pass  # Opcional: Adicione lógica aqui, se necessário

	# Mira no inimigo
	if event.is_action_pressed("ui_attack2"):  # Botão direito do mouse
		find_target()
	elif event.is_action_released("ui_attack2"):
		clear_target()  # Remove o alvo e a mira

	# Wall Jump - Pulo na parede
	if event.is_action_pressed("ui_jump") and is_wall_sliding:
		perform_wall_jump()

	# Carregamento e disparo
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


func _process(delta):
	if not projectile_enabled:
		is_charging = false
		time_since_last_shot = 0  # Reseta o cooldown de disparo se projéteis estiverem desativados
		
	if projectile_enabled and Input.is_action_pressed("ui_attack2") and current_target:
		if is_instance_valid(current_target) and current_target.is_inside_tree():

			# Atualiza a posição da mira no inimigo
			crosshair_instance.global_transform.origin = current_target.global_transform.origin
		else:
			clear_target()  # Remove o alvo e a mira se não for mais válido
			

	# Desativa a mira se o inimigo sair do raio de alcance
	if projectile_enabled and current_target and global_transform.origin.distance_to(current_target.global_transform.origin) > targeting_radius:
		clear_target()

	if dash_input_timer > 0:
		dash_input_timer -= delta  # Diminui o tempo da janela de duplo shift
		
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if is_dead:
		return  # Ignora o processamento se estiver morto

	_update_sprite_orientation()
	handle_crosshair(delta)

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
			
	 # Atualiza timer para resetar o combo de socos
	if punch_timer > 0:
		punch_timer -= delta
		if punch_timer <= 0:
			punch_count = 0

	if punch_cooldown_timer > 0:
		punch_cooldown_timer -= delta

	# Atualiza timer do lançamento de inimigos
	if throw_timer > 0:
		throw_timer -= delta
		if throw_timer <= 0 and throw_enemies_state == 1:
			# Se o jogador não pressionar novamente dentro de 0.2s, reseta o estado
			throw_enemies_state = 0

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
	if not projectile_enabled:
		return  # Não ativa a mira se projéteis estiverem desativados

	var nearby_enemies = []

	# Verifica inimigos no raio de alcance
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy and enemy.is_inside_tree():
			var distance = global_transform.origin.distance_to(enemy.global_transform.origin)
			if distance <= targeting_radius:
				nearby_enemies.append(enemy)

	if nearby_enemies.size() == 0:
		clear_target()  # Nenhum inimigo próximo
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

		# Certifica que a instância do crosshair é válida antes de usá-la
		if is_instance_valid(crosshair_instance):
			crosshair_instance.visible = true
			crosshair_instance.global_transform.origin = current_target.global_transform.origin
			print("Alvo selecionado:", closest_enemy.name)
		else:
			print("crosshair_instance não é válido!")
	else:
		clear_target()


#func update_life_bar():
	## Esconde todas as barras de vida (com verificações de null)
	#if life_bar_full and life_bar_full.is_inside_tree():
		#life_bar_full.visible = false
#
	#if life_bar_dead and life_bar_dead.is_inside_tree():
		#life_bar_dead.visible = false
#
	## Mostra a barra correspondente ao estado atual de vida
	#if current_health == 4 and life_bar_full and life_bar_full.is_inside_tree():
		#life_bar_full.visible = true
#
	#elif current_health <= 0 and life_bar_dead and life_bar_dead.is_inside_tree():
		#life_bar_dead.visible = true

func take_damage(amount: int):
	if not HealthManager.has_method("take_damage"):
		print("HealthManager não tem o método take_damage!")
		return

	HealthManager.take_damage(name, amount)
	print("Dano aplicado com sucesso!")

func die():
	is_dead = true
	#update_life_bar()
	print("Vanessa morreu!")

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
	if is_instance_valid(crosshair_instance):
		crosshair_instance.visible = false
		print("Mira desativada.")
	else:
		print("crosshair_instance já foi liberado.")

		
func _physics_process(delta):
	
	# Verifica se o avanço do soco está ativo
	if punch_timer_active > 0:
		# Armazena a altura atual antes de aplicar o avanço
		var original_y = global_transform.origin.y
		
		# Calcula o deslocamento
		var step = punch_velocity * delta
		
		# Aplica o deslocamento mantendo a altura original
		global_transform.origin += step
		global_transform.origin.y = original_y  # Restaura a altura

		punch_timer_active -= delta

		# Reseta o estado quando o tempo do soco acabar
		if punch_timer_active <= 0:
			punch_velocity = Vector3.ZERO  # Reseta a velocidade do soco
	# Verifica se o avanço do soco está ativo
	if punch_timer_active > 0:
		var step = punch_velocity * delta
		global_transform.origin += step
		punch_timer_active -= delta

		if punch_timer_active <= 0:
			punch_velocity = Vector3.ZERO  # Reseta a velocidade do soco
	var platform_velocity = Vector3.ZERO  # Variável para armazenar a velocidade da plataforma
	
	if is_dead:
		return  # Para toda lógica se estiver morta
		
	 # Verifica se o avanço do soco está ativo
	if punch_timer_active > 0:
		var step = punch_velocity * delta
		global_transform.origin += step
		punch_timer_active -= delta

		if punch_timer_active <= 0:
			punch_velocity = Vector3.ZERO  # Reseta a velocidade do soco
		
	# Impede Double Jump total
	if has_jumped and not is_on_floor():
		can_coyote_jump = false

	# 1) Aplicar gravidade com modificadores
	if not is_on_floor():
		if velocity.y > 0 and not Input.is_action_pressed("ui_jump"):
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
		# Reseta Coyote Time e estado ao tocar o chão
		coyote_timer = 0.0
		can_coyote_jump = false
		has_jumped = false  # Permite novo pulo após tocar o chão

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

	# 6) Atualiza Wall Slide
	if not is_wall_jumping:
		update_wall_slide(delta)

	# 7) Executa lógica de Wall Slide
	if is_wall_sliding:
		handle_wall_slide(delta)
	else:
		# 8) Movimentação horizontal
		_handle_input(delta)

	# 9) Executa pulo com bloqueio para evitar double jump
	if (is_on_floor() or (can_coyote_jump and not has_jumped)) and Input.is_action_just_pressed("ui_jump"):
		velocity.y = jump_speed
		has_jumped = true  # Marca que o jogador pulou

		# 🔥 Impede outro pulo instantâneo
		can_coyote_jump = false
		coyote_timer = -1.0  # Define um valor negativo para evitar ativações

		await get_tree().create_timer(0.1).timeout  # Bloqueia novos pulos por 100ms

	# 10) Adiciona a velocidade da plataforma
	if current_platform:
		# Adiciona a velocidade da plataforma somente quando necessário
		velocity.x = current_platform.velocity.x
		velocity.z = current_platform.velocity.z
	else:
		# Reduz pequenos valores residuais no eixo X e Z
		if abs(velocity.x) < 0.01:
			velocity.x = 0
		if abs(velocity.z) < 0.01:
			velocity.z = 0

	# 11) Move o personagem com colisões
	move_and_slide()

	# 🔥 Impede que outro pulo seja triggerado ao tocar o chão
	if is_on_floor():
		has_jumped = false  # Só pode pular de novo depois de tocar o chão
		can_coyote_jump = false  # Garante que o Coyote Time não "revive"

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

@onready var shoot_ray = $VanessaCamera3D/RayCast3D  # Referência ao RayCast3D dentro da câmera

func shoot_projectile():
	
	if charge_light:
			charge_light.visible = false
			print("Luz de carregamento desativada após disparo.")
	if time_since_last_shot > 0:
		return  # Respeita o cooldown de disparo

	if projectile_scene:
		var projectile = projectile_scene.instantiate()

		# Adiciona o projétil à cena
		get_parent().add_child(projectile)

		if is_first_person_active:
			# Obtém a câmera ativa
			var camera = get_viewport().get_camera_3d()
			if camera:
				# Define a origem do projétil próximo da câmera
				projectile.global_transform.origin = camera.global_transform.origin + camera.global_transform.basis.z * -1.0

				if current_target and current_target.is_inside_tree():
					# Ajusta a direção para o alvo
					var target_direction = (current_target.global_transform.origin - projectile.global_transform.origin).normalized()
					projectile.set_velocity(target_direction)
				else:
					# Define a direção do projétil como a direção da câmera
					var shoot_direction = -camera.global_transform.basis.z.normalized()
					projectile.set_velocity(shoot_direction)
		else:
			# Caso não esteja em primeira pessoa, usa a lógica padrão
			if current_target and current_target.is_inside_tree():
				projectile.global_transform.origin = shoot_origin.global_transform.origin
				projectile.set_target(current_target)  # Alvo teleguiado
			else:
				var shoot_direction = last_direction
				shoot_direction.y = 0
				shoot_direction = shoot_direction.normalized()
				projectile.global_transform.origin = shoot_origin.global_transform.origin
				projectile.set_velocity(shoot_direction)

		# Ignora colisões com o jogador
		if projectile.has_method("add_exception"):
			projectile.add_exception(self)

		# Reseta cooldown
		time_since_last_shot = shoot_cooldown
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
	# 1) Lê o input básico (WASD ou setas)
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("ui_down"):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_up"):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1

	# 2) Define a velocidade (sprint ou normal)
	var current_speed = speed
	if Input.is_action_pressed("ui_run"):
		current_speed = run_speed

	# 3) Se tem algum input, ajusta direção de acordo com a câmera
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()

		var camera_transform = get_viewport().get_camera_3d().global_transform
		var forward = -camera_transform.basis.z.normalized()
		var right = camera_transform.basis.x.normalized()

		# Converte do "input_dir local" para "mundo" seguindo a câmera
		var final_dir = (forward * input_dir.z) + (right * input_dir.x)
		final_dir = final_dir.normalized()

		# Multiplica pela velocidade escolhida
		direction = final_dir * current_speed

		# Atualiza a última direção (se precisar)
		last_direction = direction
	else:
		# Caso não haja input, desacelera suavemente
		direction = last_direction * 0.005  # 80% da direção anterior para desaceleração gradual
		if direction.length() < 0.1:  # Parar completamente se a velocidade for muito baixa
			direction = Vector3.ZERO

	# 4) Pulo normal se no chão (opcional colocar aqui)
	#    Se você preferir fazer o pulo no `_physics_process`, tudo bem.
	if is_on_floor():
		if Input.is_action_just_pressed("ui_jump"):
			velocity.y = jump_speed

	# 5) Aplica a direction no eixo X e Z da velocity
	velocity.x = direction.x
	velocity.z = direction.z

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
	platform_velocity = platform.velocity  # Obtenha a velocidade da plataforma
	print("Entrou na plataforma:", platform.name)

func _on_platform_exited(platform):
	if current_platform == platform:
		current_platform = null
		platform_velocity = Vector3.ZERO
	print("Saiu da plataforma:", platform.name)

# Função que executa o dash
func perform_dash(delta):
	if dash_timer > 0:
		dash_timer -= delta
		var original_y = velocity.y  # Mantém a altura atual
		velocity = dash_direction * dash_speed  # Aplica o dash na direção horizontal
		velocity.y = original_y  # Preserva o valor do eixo Y
		move_and_slide()
	else:
		is_dashing = false  # Termina o dash

func start_dash():
	if is_dashing or dash_cooldown_timer > 0:
		return  # Não permite iniciar o dash se já estiver ativo ou em cooldown

	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown

	# Define a direção do dash com base na direção atual
	if direction.length() > 0:
		dash_direction = direction.normalized()
	else:
		dash_direction = last_direction.normalized()
		
func _on_first_person_toggled(active):
	is_first_person_active = active
		
		
func heal(amount):
	if current_health < max_health:  # Garante que não passe do máximo
		current_health += amount
		if current_health > max_health:
			current_health = max_health
		print("Curado! Vida atual: ", current_health)
		#update_life_bar()  # Atualiza a interface da vida
		
func reset_shooting_state():
	is_charging = false
	charge_time = 0.0
	time_since_last_shot = 0.0  # Reseta o cooldown de disparo
	punch_cooldown_timer = 0.0  # Reseta o cooldown do soco
	if charge_light:
		charge_light.visible = false  # Esconde a luz de carregamento
	if crosshair_instance:
		crosshair_instance.visible = false  # Esconde a mira
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

#func show_all_life_bars():
	#update_life_bar()  # Garante que apenas a barra correspondente ao estado atual seja exibida
	
#func hide_all_life_bars():
	#if life_bar_full:
		#life_bar_full.visible = false
#
	#if life_bar_dead:
		#life_bar_dead.visible = false
		#
		#
		
func perform_punch():
	if punch_cooldown_timer > 0:
		return

	if punch_timer <= 0:
		punch_count = 0  # Reseta o combo se o timer do soco acabou

	punch_count += 1
	punch_timer = 0.5  # Reinicia o timer para manter o combo

	# Define a distância do avanço com base no combo
	var distance = punch_distance
	if punch_count == 3:
		distance = punch_distance_third
		punch_cooldown_timer = 0.5  # Cooldown maior após o terceiro soco
		punch_count = 0  # Reseta o combo

	# Salva a altura original
	var original_y = global_transform.origin.y

	# Define a direção do soco
	var punch_direction: Vector3

	if is_first_person_active:
		# Usa a direção do `crosshair` (baseada no RayCast da câmera)
		if shoot_ray and shoot_ray.is_colliding():
			var target_position = shoot_ray.get_collision_point()
			punch_direction = (target_position - global_transform.origin).normalized()
		else:
			# Caso não haja colisão, usa a direção da câmera
			punch_direction = -camera.global_transform.basis.z.normalized()
	else:
		# Direção padrão com base na última direção horizontal
		punch_direction = last_direction
		punch_direction.y = 0  # Remove o componente vertical
		punch_direction = punch_direction.normalized()

	# Verifica se o jogador está pressionando teclas de movimentação
	if direction.length() > 0:
		# Calcula a velocidade do avanço
		punch_velocity = punch_direction * 10.0 * distance
	else:
		# Sem movimento, Vanessa não avança
		punch_velocity = Vector3.ZERO

	punch_timer_active = punch_duration  # Ativa o temporizador do avanço do soco

	# Mantém a altura constante
	global_transform.origin.y = original_y

	# Mostra o efeito visual do soco
	show_punch_effect()

	# Aplica dano aos inimigos na área
	apply_area_damage_with_area(punch_damage)

	print("Soco executado! Distância:", distance, "Direção:", punch_velocity)
	print("Altura original:", original_y, "Altura atual:", global_transform.origin.y)

func spawn_punch_explosion(center: Vector3, radius: float):
	if punch_explosion_scene:
		var explosion = punch_explosion_scene.instantiate()
		explosion.global_transform.origin = center  # Define o centro na área de impacto
		# Ajusta a escala da explosão de acordo com o raio
		explosion.scale = Vector3.ONE * radius
		get_parent().add_child(explosion)
	else:
		print("Piggor: punch_explosion_scene não configurada!")

		
# Função para aplicar dano aos inimigos na área
func apply_area_damage_with_area(damage: int):
	var area = $PunchAOE
	if not area or not area.is_inside_tree():
		print("Área de soco não encontrada!")
		return

	# Verifica todos os corpos dentro do `Area3D`
	# Verifica todos os corpos dentro do `Area3D`
	for body in area.get_overlapping_bodies():
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				# Aplica dano ao inimigo
				var push_direction = (body.global_transform.origin - global_transform.origin).normalized()
				push_direction.y += 0.3  # Adiciona um leve impulso para cima
				body.take_damage(damage, push_direction)
				print("Dano causado ao inimigo:", body.name)
			else:
				print("Inimigo não possui o método 'take_damage':", body.name)

				# Calcula o impulso com base na posição da Vanessa e do inimigo
				var push_direction = (body.global_transform.origin - global_transform.origin).normalized()
				push_direction.y += 0.3  # Adiciona um leve impulso para cima
				push_direction = push_direction.normalized()

				# Aplica o impulso ao inimigo (caso ele seja RigidBody ou KinematicBody)
				if body.has_method("apply_impulse"):
					body.apply_impulse(Vector3.ZERO, push_direction * 10)  # Ajuste a força do empurrão
				elif body.has_method("move_and_slide"):
					body.velocity += push_direction * 10  # Para KinematicBodies

				else:
					print("Inimigo não possui o método 'take_damage':", body.name)

func perform_enemy_throw():
	thrown_enemies.clear()
	# Procura inimigos próximos para lançar
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy and enemy.is_inside_tree():
			if enemy.global_transform.origin.distance_to(global_transform.origin) <= throw_radius:
				# Aplica impulso para cima – ajuste de acordo com a implementação do inimigo
				if enemy.has_method("apply_impulse"):
					enemy.apply_impulse(Vector3.UP * throw_up_force)
				else:
					# Se o inimigo for do tipo Kinematic, você pode definir uma propriedade ou chamar um método customizado
					enemy.velocity.y = throw_up_force  # Exemplo; ajuste conforme seu setup
				thrown_enemies.append(enemy)
	if thrown_enemies.size() > 0:
		throw_enemies_state = 1
		throw_timer = 0.2
		
		
func perform_enemy_slam():
	# Vanessa desce suavemente – você pode ajustar a animação ou a velocidade
	velocity.y = -slam_down_force
	# Aplica dano e “esmaga” os inimigos que foram lançados
	for enemy in thrown_enemies:
		if enemy and enemy.is_inside_tree():
			if enemy.has_method("take_damage"):
				enemy.take_damage(slam_damage)
	# Reseta o estado
	thrown_enemies.clear()
	throw_enemies_state = 0
	throw_timer = 0.0
	
func show_punch_effect():
	if not punch_effect or not punch_effect.is_inside_tree():
		return

	var punch_position: Vector3
	var forward_direction: Vector3
	var height_offset: float = 0.0  # Ajuste fino para altura do efeito

	if is_first_person_active:
		if shoot_ray and shoot_ray.is_colliding():
			var collision_point = shoot_ray.get_collision_point()
			var distance_to_collision = global_transform.origin.distance_to(collision_point)
			
			if distance_to_collision > 5.0:  
				forward_direction = -camera.global_transform.basis.z.normalized()
				punch_position = global_transform.origin + forward_direction * 1.5
			else:
				punch_position = collision_point
				forward_direction = (collision_point - global_transform.origin).normalized()
		else:
			forward_direction = -camera.global_transform.basis.z.normalized()
			punch_position = global_transform.origin + forward_direction * 1.5
	else:
		forward_direction = last_direction.normalized()
		punch_position = global_transform.origin + forward_direction * 1.5

	# 🔥 **Correção da Altura**
	punch_position.y = global_transform.origin.y + height_offset  

	# Aplica a posição e visibilidade do efeito de soco
	punch_effect.global_transform.origin = punch_position
	punch_effect.visible = true

	# 🔥 **Correção para o PunchAOE**
	if punch_aoe and punch_aoe.is_inside_tree():
		const FIXED_DISTANCE: float = 2.0
		punch_aoe.global_transform.origin = global_transform.origin + forward_direction * FIXED_DISTANCE
		punch_aoe.global_transform.origin.y = global_transform.origin.y + height_offset  # Ajuste fino da altura
		punch_aoe.look_at(punch_aoe.global_transform.origin + forward_direction, Vector3.UP)
		punch_aoe.visible = true

	# Ajuste para o efeito de luz do soco
	if punch_light and punch_light.is_inside_tree():
		punch_light.global_transform.origin = punch_position
		punch_light.visible = true

	await get_tree().create_timer(0.3).timeout
	punch_effect.visible = false
	if punch_light:
		punch_light.visible = false

func deactivate_character():
	# Lógica para desativar o personagem
	self.hide()
	self.set_physics_process(false)
	self.set_process(false)

func activate_character():
	# Lógica para ativar o personagem
	self.show()
	self.set_physics_process(true)
	self.set_process(true)
