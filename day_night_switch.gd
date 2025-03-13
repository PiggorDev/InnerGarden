extends Node3D

@export var night_environment: Environment  # Arraste um Environment noturno no Inspetor
@export var day_environment: Environment  # Arraste o Environment diurno no Inspetor

var player_inside = false
var is_night = false  # Variável para alternar entre dia e noite
var world_environment: WorldEnvironment = null
var original_environment: Environment = null  # Armazena o ambiente original do jogo

func _ready():
	# ⚠️ Tente encontrar o WorldEnvironment pelo caminho direto
	world_environment = $"../WorldEnvironment" as WorldEnvironment
	
	# Se não encontrou, tente pegar pelo grupo
	if not world_environment:
		world_environment = get_tree().get_first_node_in_group("WorldEnvironment") as WorldEnvironment

	# Se ainda não encontrou, exibir erro
	if not world_environment:
		print("❌ ERRO: WorldEnvironment não encontrado! Certifique-se de que ele está na cena e no grupo 'WorldEnvironment'.")
		return  # Sai da função para evitar erros
	
	# ⚠️ Armazena o ambiente original para restaurar depois
	original_environment = world_environment.environment

	var area = $Area3D  # Pegamos a `Area3D` dentro deste nó
	if area:
		area.connect("body_entered", Callable(self, "_on_area_3d_body_entered"))
		area.connect("body_exited", Callable(self, "_on_area_3d_body_exited"))
		print("✅ Conectado aos sinais de colisão!")
	else:
		print("❌ ERRO: Area3D não encontrada!")

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		print("✅ Player entrou na área!")  # Debug
		player_inside = true

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		print("❌ Player saiu da área!")  # Debug
		player_inside = false

func _input(event):
	if event.is_action_pressed("ui_interact"):
		print("🔍 Tentando interagir...")  # Debug
		if player_inside:  
			print("✅ Interagiu dentro da área!")  # Debug
			switch_to_night()
		else:
			print("❌ Tentou interagir fora da área!")  # Debug

func switch_to_night():
	if not world_environment:
		print("❌ ERRO: WorldEnvironment ainda não foi encontrado!")
		return

	if is_night:
		print("☀ Voltando para o ambiente original!")  # Debug
		world_environment.environment = original_environment  # Restaura o ambiente original
		is_night = false
	else:
		print("🌙 Mudando para noite!")  # Debug
		world_environment.environment = night_environment  # Muda para noite
		is_night = true
