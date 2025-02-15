extends Node3D
#
## Referência ao MeshInstance3D
#var sprite3D: Sprite3D = null
#
#func _ready():
	## Tenta acessar o MeshInstance3D dentro do CharacterBody3D
	#if has_node("Libu/Sprite3D"):
		#sprite3D = $Libu/Sprite3D
		#
#
#
#func _process(_delta):
	#if Sprite3D and sprite3D.is_inside_tree():
#
		## Faz o MeshInstance3D olhar para a câmera ativa
		#sprite3D.look_at(get_viewport().get_camera_3d().global_transform.origin)
	#else:
		#print("MeshInstance3D não encontrado ou fora da árvore no _process()!")
