extends Node3D

@onready var area = $Area3D  # Referência à área que detecta o jogador
@onready var animation_player = $AnimationPlayer  # Referência ao AnimationPlayer

var is_open = false  # Estado atual da porta
var player_inside = false  # O jogador está dentro da área?
var can_interact = true  # Controle de interação para evitar spam de abertura/fechamento

func _ready():
	# Verifica se a AnimationPlayer existe
	if animation_player == null:
		print("⚠️ AnimationPlayer não encontrado! Certifique-se de que há um AnimationPlayer na cena.")
		return  # Evita erros caso o nó não exista
	
	# Conecta os sinais corretamente
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	# Conecta o sinal de término de animação para liberar a interação
	animation_player.animation_finished.connect(_on_animation_finished)

func _process(_delta):
	# Verifica se o jogador está dentro da área, apertou "Z" e pode interagir
	if player_inside and can_interact and Input.is_action_just_pressed("ui_interact"):
		toggle_door()

func toggle_door():
	# Garante que o AnimationPlayer existe antes de tocar a animação
	if animation_player and animation_player.has_animation("door_open") and animation_player.has_animation("door_closed"):
		# Bloqueia interação enquanto a animação está tocando
		can_interact = false
		
		if is_open:
			animation_player.play("door_open")
		else:
			animation_player.play("door_closed")

		is_open = !is_open
	else:
		print("❌ Erro: AnimationPlayer não está definido ou as animações não existem!")

func _on_animation_finished(anim_name):
	# Reativa a interação quando a animação terminar
	can_interact = true
	print("✅ Animação finalizada, interação liberada:", anim_name)

func _on_body_entered(body):
	# Detecta se o jogador entrou na área corretamente
	if body and (body.name == "Libu" or body.name == "Vanessa"):  # Substitua pelo nome do nó do jogador
		player_inside = true
		print("🔹 Jogador entrou na área da porta.")

func _on_body_exited(body):
	# Detecta se o jogador saiu da área corretamente
	if body and (body.name == "Libu" or body.name == "Vanessa"):
		player_inside = false
		print("🔸 Jogador saiu da área da porta.")
