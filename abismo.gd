extends Area3D




func _on_body_entered(body):
	if body.is_in_group("Player"):  # Certifique-se de que o jogador está no grupo "Player"
		body.take_damage(body.current_health)  # Causa dano suficiente para "matar" o jogador, ou
		get_tree().reload_current_scene()  # Reinicia a cena, por exemplo
