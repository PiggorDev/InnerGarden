extends Control

# Referência para a barra de vida da Libu
@onready var libu_bar = $LifeBar_Libu

# Função principal para atualizar a barra de vida da Libu
func update_libu_life(health: int):
	print("DEBUG: Atualizando barra de vida da Libu com vida:", health)
	
	# Esconde todos os estados da barra de vida da Libu
	for child in libu_bar.get_children():
		child.visible = false
		print("DEBUG: Escondendo nó:", child.name)
	
	# Mostra o estado correspondente à vida atual
	match health:
		2:
			if libu_bar.has_node("HUD_Life_Full_Libu"):
				libu_bar.get_node("HUD_Life_Full_Libu").visible = true
				print("DEBUG: Mostrando HUD_Life_Full_Libu")
		1:
			if libu_bar.has_node("HUD_Life_Hurt_Libu"):
				libu_bar.get_node("HUD_Life_Hurt_Libu").visible = true
				print("DEBUG: Mostrando HUD_Life_Hurt_Libu")
		0:
			if libu_bar.has_node("HUD_Life_Dead_Libu"):
				libu_bar.get_node("HUD_Life_Dead_Libu").visible = true
				print("DEBUG: Mostrando HUD_Life_Dead_Libu")
		_:
			print("DEBUG: Estado de vida desconhecido:", health)

# Esconde tudo no início para evitar problemas
func _ready():
	print("DEBUG: Escondendo tudo no início.")
	update_libu_life(0)  # Inicialmente deixa como morto para esconder tudo
