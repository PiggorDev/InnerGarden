extends Node3D

func _ready():
	# Itera por todos os filhos do Node3D atual
	for node in get_children():
		# Verifica se o nó é StaticBody3D e não é o Player (Libu)
		if node is StaticBody3D and not node.is_in_group("Player"):
			# Verifica se o nó tem um CollisionShape3D
			if node.has_node("CollisionShape3D"):
				# Adiciona ao grupo "Wall" se ainda não estiver
				if not node.is_in_group("Wall"):
					node.add_to_group("Wall")
					print(node.name + " adicionado ao grupo Wall")
