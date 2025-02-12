extends Area3D

var can_interact = false

func _ready():
	monitoring = true  # (Pode ativar no Inspector também)
	# CollisionShape2D também precisa estar configurado

func _on_InteractArea_body_entered(body):
	if body.is_in_group("Player"):
		can_interact = true

func _on_InteractArea_body_exited(body):
	if body.is_in_group("Player"):
		can_interact = false

func _process(delta):
	if can_interact and Input.is_action_just_pressed("ui_interact"):
		# "Sobe" a chamada para o pai, que tem o AnimationPlayer
		get_parent().start_cutscene()
