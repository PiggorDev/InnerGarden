extends Node

func _ready():
	# Obtenha o número total de monitores
	var monitor_count = DisplayServer.get_screen_count()
	print("Monitores detectados: ", monitor_count)

	# Escolha o segundo monitor (índice 1, já que a contagem começa do zero)
	var display_index = 1  
	if display_index >= monitor_count:
		print("Monitor especificado não existe. Usando monitor principal.")
		display_index = 0

	# Obtenha as dimensões e posição do monitor escolhido
	var screen_size = DisplayServer.screen_get_size(display_index)
	var screen_position = DisplayServer.screen_get_position(display_index)

	# **Garante que a posição seja aplicada APÓS a janela ser criada**
	await get_tree().process_frame  

	# Configurar a posição e tamanho da janela do jogo
	DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)  # Modo janela normal
	DisplayServer.window_set_size(screen_size * 1)  # 80% do tamanho do monitor
	DisplayServer.window_set_position(screen_position)  # Move para o segundo monitor

	# Debugging para verificar se está correto
	print("Janela configurada para o monitor ", display_index)
	print("Tamanho da tela: ", screen_size, " Posição: ", screen_position)
