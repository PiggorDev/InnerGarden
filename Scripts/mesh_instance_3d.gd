extends Node3D

@onready var anim_player = $AnimationPlayer

func _ready():
	print("Tentando reproduzir animação...")
	anim_player.play("BABA")
	print("Animação atual:", anim_player.current_animation)
