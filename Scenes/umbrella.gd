# umbrella.gd
extends "res://Scenes/item_base.gd"

var is_active = false

func use(player):
	print("Usando o guarda-chuva!")
	# Ativa o comportamento do guarda-chuva
	is_active = true
	player.set_umbrella_active(true)

func stop_using(player):
	print("Parando de usar o guarda-chuva!")
	# Desativa o comportamento do guarda-chuva
	is_active = false
	player.set_umbrella_active(false)
