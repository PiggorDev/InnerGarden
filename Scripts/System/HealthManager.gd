#extends Node
#
#signal character_switched(new_character)
#
#var libu_health: int = 2
#var vanessa_health: int = 4
#var soul_health: int = 1
#var is_invincible = false
#var invincibility_time = 1.0
#var canvas_layer: Node = null
#var hud_libu: Node = null
#var hud_vanessa: Node = null
#var hud_soul: Node = null
#
#func _ready():
	## Verifica e configura o CanvasLayer
	#if not canvas_layer:
		#canvas_layer = get_node_or_null("/root/Node3D/CanvasLayer")  # Ajuste o caminho se necessário
		#if not canvas_layer:
			#print("Erro: CanvasLayer não encontrado no _ready.")
			#return
#
	#print("CanvasLayer configurado com sucesso:", canvas_layer.name)
#
	## Localiza HUDs
	#find_huds()
#
	## Verifica se as HUDs foram localizadas
	#if not hud_libu or not hud_vanessa or not hud_soul:
		#print("Erro: Nem todas as HUDs foram localizadas no _ready.")
		#return
#
	#print("Iniciando configuração da HUD...")
#
	#await get_tree().process_frame  # Espera um frame para garantir que as HUDs estão inicializadas
	#update_hud("Libu", libu_health)
	#print("HUD inicial configurada para Libu:", hud_libu)
#
#
	## Verifica visibilidade
	#check_visibility()
#
	## Testa filhos do CanvasLayer para depuração
	#print("Filhos do CanvasLayer:")
	#for child in canvas_layer.get_children():
		#print(child.name)
#
	## Testa caminhos diretos para depuração
	#print("Tentando localizar nós diretamente no CanvasLayer:")
	#var test_libu = canvas_layer.get_node_or_null("LifeBars/LifeBar_Libu")
	#if test_libu:
		#print("LifeBar_Libu encontrada:", test_libu.name)
	#else:
		#print("Erro: LifeBar_Libu não encontrada.")
#
	#var test_vanessa = canvas_layer.get_node_or_null("LifeBars/LifeBar_Vanessa")
	#if test_vanessa:
		#print("LifeBar_Vanessa encontrada:", test_vanessa.name)
	#else:
		#print("Erro: LifeBar_Vanessa não encontrada.")
#
	#var test_soul = canvas_layer.get_node_or_null("LifeBars/LifeBar_Soul")
	#if test_soul:
		#print("LifeBar_Soul encontrada:", test_soul.name)
	#else:
		#print("Erro: LifeBar_Soul não encontrada.")
#
#func set_canvas_layer(layer: Node):
	#if not layer:
		#print("Erro: Tentativa de configurar CanvasLayer com um valor nulo.")
		#return
#
	#self.canvas_layer = layer  # Atribui o CanvasLayer recebido
	#print("CanvasLayer configurado com sucesso:", self.canvas_layer.name)
#
	#await get_tree().process_frame  # Aguarda um frame
	#find_huds()  # Localiza todas as HUDs
#
	#if not hud_libu or not hud_vanessa or not hud_soul:
		#print("Erro: Nem todas as HUDs foram localizadas no set_canvas_layer.")
		#return
#
	#print("HUDs localizadas com sucesso!")
#
	##hide_all_life_bars()  # Esconde todas as barras antes de mostrar a inicial
	#await get_tree().process_frame  # Espera um frame para garantir que as HUDs estão inicializadas
	#update_hud("Libu", libu_health)
	#print("HUD inicial configurada para Libu:", hud_libu)
#
#
##func hide_all_life_bars():
	##print("DEBUG: Ocultando todas as barras de vida!")
##
	##if hud_libu:
		##hud_libu.get_node("HUD_Life_Full_Libu").visible = false
		##hud_libu.get_node("HUD_Life_Hurt_Libu").visible = false
		##hud_libu.get_node("HUD_Life_Dead_Libu").visible = false
	##if hud_vanessa:
		##hud_vanessa.get_node("HUD_Life_Full_Vanessa").visible = false
		##hud_vanessa.get_node("HUD_Life_Hurt_Vanessa").visible = false
		##hud_vanessa.get_node("HUD_Life_Hurt2_Vanessa").visible = false
		##hud_vanessa.get_node("HUD_Life_Hurt3_Vanessa").visible = false
		##hud_vanessa.get_node("HUD_Life_Dead_Vanessa").visible = false
	##if hud_soul:
		##hud_soul.get_node("HUD_Life_Full_Soul").visible = false
		##hud_soul.get_node("HUD_Life_Dead_Soul").visible = false
##
	##print("Todas as barras de vida foram ocultadas.")
#
#func update_hud(active_character: String, health: int):
	#print("DEBUG: Verificando HUD antes de atualizar")
	#print("Libu HUD:", hud_libu)
	#print("Vanessa HUD:", hud_vanessa)
	#print("Soul HUD:", hud_soul)
#
	## Certifique-se de ocultar todas as barras antes de mostrar a ativa
	##hide_all_life_bars()
#
	#print("Atualizando HUD para:", active_character, "com vida:", health)
#
	#match active_character:
		#"Libu":
			#if hud_libu:
				#update_libu_hud(health)
				#print("HUD Libu atualizada e visível.")
			#else:
				#print("Erro: HUD Libu não encontrada.")
		#"Vanessa":
			#if hud_vanessa:
				#update_vanessa_hud(health)
				#print("HUD Vanessa atualizada e visível.")
			#else:
				#print("Erro: HUD Vanessa não encontrada.")
		#"Soul":
			#if hud_soul:
				#update_soul_hud(health)
				#print("HUD Soul atualizada e visível.")
			#else:
				#print("Erro: HUD Soul não encontrada.")
		#_:
			#print("Erro: Personagem desconhecido:", active_character)
#
#func update_libu_hud(health: int):
	#if hud_libu:
		#if health == 2:
			#hud_libu.get_node("HUD_Life_Full_Libu").visible = true
			#print("Mostrando HUD_Life_Full_Libu")
		#elif health == 1:
			#hud_libu.get_node("HUD_Life_Hurt_Libu").visible = true
			#print("Mostrando HUD_Life_Hurt_Libu")
		#elif health <= 0:
			#hud_libu.get_node("HUD_Life_Dead_Libu").visible = true
			#print("Mostrando HUD_Life_Dead_Libu")
		#else:
			#print("Estado de saúde desconhecido para Libu:", health)
	#else:
		#print("Erro: Nó hud_libu não encontrado.")
#
#func update_vanessa_hud(health: int):
	#if health == 4:
		#hud_vanessa.get_node("HUD_Life_Full_Vanessa").visible = true
	#elif health == 3:
		#hud_vanessa.get_node("HUD_Life_Hurt_Vanessa").visible = true
	#elif health == 2:
		#hud_vanessa.get_node("HUD_Life_Hurt2_Vanessa").visible = true
	#elif health == 1:
		#hud_vanessa.get_node("HUD_Life_Hurt3_Vanessa").visible = true
	#elif health <= 0:
		#hud_vanessa.get_node("HUD_Life_Dead_Vanessa").visible = true
	#else:
		#print("Estado de saúde desconhecido para Vanessa:", health)
#
#func update_soul_hud(health: int):
	#if health == 1:
		#hud_soul.get_node("HUD_Life_Full_Soul").visible = true
	#elif health <= 0:
		#hud_soul.get_node("HUD_Life_Dead_Soul").visible = true
	#else:
		#print("Estado de saúde desconhecido para Soul:", health)
#
#func take_damage(character: String, damage: int):
	#if is_invincible:
		#print("Dano ignorado - Invencível")
		#return
#
	#match character:
		#"Libu":
			#libu_health -= damage
			#if libu_health <= 0:
				#libu_health = 0
				#handle_death("Libu")
		#"Vanessa":
			#vanessa_health -= damage
			#if vanessa_health <= 0:
				#vanessa_health = 0
				#handle_death("Vanessa")
		#"Soul":
			#soul_health -= damage
			#if soul_health <= 0:
				#soul_health = 0
				#handle_death("Soul")
#
	#is_invincible = true
	#print(character + " está invencível por", invincibility_time, "segundos")
	#await get_tree().create_timer(invincibility_time).timeout
	#is_invincible = false
	#print(character + " não está mais invencível")
#
	#match character:
		#"Libu":
			#update_hud("Libu", libu_health)
		#"Vanessa":
			#update_hud("Vanessa", vanessa_health)
		#"Soul":
			#update_hud("Soul", soul_health)
#
#func handle_death(character: String):
	#print(character + " morreu!")
#
#func switch_character(new_character: String):
	#character_switched.emit(new_character)
#
	#match new_character:
		#"Libu":
			#update_hud("Libu", libu_health)
		#"Vanessa":
			#update_hud("Vanessa", vanessa_health)
		#"Soul":
			#update_hud("Soul", soul_health)
#
#func find_huds():
	#if not canvas_layer:
		#print("Erro: CanvasLayer não está configurado.")
		#return
		#
	#print("Procurando HUDs dentro do CanvasLayer:", canvas_layer.name)
#
	#hud_libu = canvas_layer.get_node_or_null("LifeBars/LifeBar_Libu")
	#hud_vanessa = canvas_layer.get_node_or_null("LifeBars/LifeBar_Vanessa")
	#hud_soul = canvas_layer.get_node_or_null("LifeBars/LifeBar_Soul")
	#
	#print("HUDs encontradas:", hud_libu, hud_vanessa, hud_soul)
#
	#if hud_libu:
		#print("HUD Libu encontrada com sucesso:", hud_libu.name)
	#else:
		#print("Erro: HUD Libu não encontrada.")
#
	#if hud_vanessa:
		#print("HUD Vanessa encontrada com sucesso:", hud_vanessa.name)
	#else:
		#print("Erro: HUD Vanessa não encontrada.")
#
	#if hud_soul:
		#print("HUD Soul encontrada com sucesso:", hud_soul.name)
	#else:
		#print("Erro: HUD Soul não encontrada.")
		#
#func check_visibility():
	#if hud_libu:
		#print("Libu - Full visible:", hud_libu.get_node("HUD_Life_Full_Libu").visible)
		#print("Libu - Hurt visible:", hud_libu.get_node("HUD_Life_Hurt_Libu").visible)
		#print("Libu - Dead visible:", hud_libu.get_node("HUD_Life_Dead_Libu").visible)
	#else:
		#print("Erro: HUD Libu não configurada.")
#
	#if hud_vanessa:
		#print("Vanessa - Full visible:", hud_vanessa.get_node("HUD_Life_Full_Vanessa").visible)
	#else:
		#print("Erro: HUD Vanessa não configurada.")
#
	#if hud_soul:
		#print("Soul - Full visible:", hud_soul.get_node("HUD_Life_Full_Soul").visible)
	#else:
		#print("Erro: HUD Soul não configurada.")
