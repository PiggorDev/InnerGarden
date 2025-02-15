extends Node3D

func _ready():
	# Itera por todos os filhos do Proto_env
	for child in get_children():
		if child is Node3D:  # Verifica se o filho é Node3D
			# Procura um MeshInstance3D como filho do Node3D
			var mesh_instance = child.get_node_or_null("MeshInstance3D")
			
			if mesh_instance and mesh_instance.mesh:
				# Cria um StaticBody3D como filho do Node3D
				var static_body = StaticBody3D.new()
				child.add_child(static_body)
				static_body.global_transform = mesh_instance.global_transform
				
				# Adiciona uma forma de colisão
				var collision_shape = CollisionShape3D.new()
				static_body.add_child(collision_shape)
				
				# Gera a colisão baseada na malha
				collision_shape.shape = mesh_instance.mesh.create_trimesh_shape()
