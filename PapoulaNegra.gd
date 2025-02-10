extends Area3D

@export var heal_amount: int = 1  # Quantidade de cura
@export var float_speed: float = 1.5  # Velocidade da flutuação
@export var float_height: float = 0.2  # Altura máxima da flutuação

var base_position: Vector3  # Posição original da flor
var time_passed: float = 0.0  # Tempo decorrido para o movimento

func _ready():
	base_position = global_transform.origin  # Armazena a posição inicial
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	time_passed += delta
	# Move para cima e para baixo usando uma função senoide
	global_transform.origin.y = base_position.y + sin(time_passed * float_speed) * float_height

func _on_body_entered(body):
	if body.has_method("heal"):
		body.heal(heal_amount)  # Cura o jogador
		queue_free()  # Remove a flor da cena
