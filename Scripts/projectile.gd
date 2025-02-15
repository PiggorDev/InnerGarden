extends Node3D

@export var speed: float = 10.0
@export var lifetime: float = 2.0
var velocity: Vector3 = Vector3.ZERO # Inicializa como vetor zero

func _ready():
	# Destrói o projetil após o tempo de vida
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	# Move o projetil para frente
	global_translate(velocity * speed * delta)

# Define a direção do projetil
func set_velocity(direction: Vector3):
	velocity = direction.normalized()
