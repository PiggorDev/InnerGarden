extends Node2D

# Nome da cena de protótipo
@export var prototype_scene: PackedScene


	

func _input(event):
	# Detecta quando o jogador pressiona "Enter"
	if event.is_action_pressed("ui_accept"):  # "ui_accept" mapeado para Enter no Godot
		change_to_prototype()


func change_to_prototype():
	get_tree().change_scene_to_file("res://GrassTest.tscn")
