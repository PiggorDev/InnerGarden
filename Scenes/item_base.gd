# item_base.gd
extends Node

@export var item_name: String = "Item Genérico"
@export var description: String = "Descrição do item."
@export var icon: Texture  # Ícone para inventário

# Método chamado quando o item é usado
func use(player):
	print("O item", item_name, "foi usado.")
