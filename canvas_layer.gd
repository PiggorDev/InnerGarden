extends CanvasLayer

# Número de slots no inventário e na Hotbar
@export var num_inventory_slots: int = 4
@export var num_hotbar_slots: int = 1

var inventory_slots: Array = []
var hotbar_slots: Array = []

@onready var container = $Inventory/VBoxContainer  # Contêiner do inventário$Inventory/VBoxContainer
@onready var hotbar_container = $Inventory/Hotbar  # HBoxContainer da Hotbar$Inventory/Hotbar
@onready var inventory_rect = $Inventory/InventoryRect  # TextureRect para escurecer a tela$Inventory/InventoryRect
@onready var player = get_tree().get_first_node_in_group("Player")  # Certifique-se de que o nó do jogador pertence ao grupo "Player"
var inventory_items: Array = []  # Lista para armazenar os itens do inventário


func _ready():
	# Configura os destaques para cada slot no inventário
	for i in range(container.get_child_count()):
		var slot = container.get_child(i)
		if slot.has_node("Highlight"):
			var highlight = slot.get_node("Highlight")
			highlight.modulate = Color(1, 1, 1, 0)  # Inicializa invisível
			slot.connect("mouse_entered", Callable(self, "_on_mouse_entered").bind(highlight))
			slot.connect("mouse_exited", Callable(self, "_on_mouse_exited").bind(highlight))

	# Configura os destaques para cada slot na Hotbar (🔹 ADICIONADO!)
	for i in range(hotbar_container.get_child_count()):
		var hotbar_slot = hotbar_container.get_child(i)
		if hotbar_slot.has_node("Highlight"):
			var highlight = hotbar_slot.get_node("Highlight")
			highlight.modulate = Color(1, 1, 1, 0)  # Inicializa invisível
			hotbar_slot.connect("mouse_entered", Callable(self, "_on_mouse_entered").bind(highlight))
			hotbar_slot.connect("mouse_exited", Callable(self, "_on_mouse_exited").bind(highlight))

	# Inicializa os slots do inventário
	for i in range(container.get_child_count()):
		var slot = container.get_child(i)
		inventory_slots.append(null)  # Define os slots como vazios inicialmente
		slot.connect("gui_input", Callable(self, "_on_slot_gui_input").bind(i))

	# Inicializa os slots da HotBar e conecta eventos de clique
	hotbar_slots = []  # Garante que está vazio antes de inicializar
	for i in range(hotbar_container.get_child_count()):
		var hotbar_slot = hotbar_container.get_child(i)
		hotbar_slots.append(null)  # Define os slots da HotBar como vazios inicialmente
		hotbar_slot.connect("gui_input", Callable(self, "_on_hotbar_gui_input").bind(i))  # Conecta evento

	# Inicializa o estado inicial
	container.visible = false
	inventory_rect.visible = false

func _process(delta):
	# Verifica se o primeiro slot da hotbar está ocupado e equipa o item
	if hotbar_slots[0] != null:
		equip_item(hotbar_slots[0])  # Sempre equipa o item no primeiro slot da hotbar
	else:
		equip_item(null)  # Remove o item se o slot estiver vazio
	# Verifica se o botão está pressionado
	if Input.is_action_pressed("ui_inventory"):  # Segurando TAB
		show_inventory()
	else:
		hide_inventory()

# Função para mostrar o inventário
func show_inventory():
	container.visible = true
	inventory_rect.visible = true
	show_mouse()

# Função para esconder o inventário
func hide_inventory():
	container.visible = false
	inventory_rect.visible = false
	hide_mouse()

# Função para mostrar o mouse
func show_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Função para esconder o mouse
func hide_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Função para adicionar um item ao inventário
func add_item_to_slot(item: Texture) -> bool:
	for i in range(num_inventory_slots):
		if inventory_slots[i] == null:  # Verifica se o slot está vazio
			inventory_slots[i] = item  # Adiciona logicamente o item ao inventário

			# Obtém o slot correspondente
			var slot = container.get_child(i)
			
			# Verifica se o nó 'Item' existe dentro do slot
			if slot.has_node("Item"):
				var item_rect = slot.get_node("Item")
				if item_rect:
					item_rect.texture = item  # Define a textura do item
					item_rect.visible = true  # Garante que o item está visível
					return true

	return false

# Função chamada ao clicar em um slot
func _on_slot_gui_input(event: InputEvent, slot_index: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		move_item_to_hotbar(slot_index)

# Função para mover um item de um slot para a Hotbar
func move_item_to_hotbar(slot_index: int):
	if inventory_slots[slot_index] != null:
		for i in range(num_hotbar_slots):
			if hotbar_slots[i] == null:
				var hotbar_slot = hotbar_container.get_child(i)
				if not hotbar_slot:
					return
				var item_rect = hotbar_slot.get_node("Item") if hotbar_slot.has_node("Item") else null
				if not item_rect:
					return

				# Atualiza o Sprite3D com a textura do item
				equip_item(inventory_slots[slot_index])  # Aqui é chamado

				item_rect.texture = inventory_slots[slot_index]
				item_rect.visible = true
				hotbar_slots[i] = inventory_slots[slot_index]
				inventory_slots[slot_index] = null

				var inventory_slot = container.get_child(slot_index)
				if inventory_slot.has_node("Item"):
					var inventory_item_rect = inventory_slot.get_node("Item")
					inventory_item_rect.texture = null
					inventory_item_rect.visible = false
				return

# Função para entregar um item ao jogador
func give_item_to_player(item: Texture):
	var added = add_item_to_slot(item)

# Função para quando o mouse entra em um slot
# Variável para armazenar os tweens ativos
var active_tweens: Dictionary = {}

func _on_mouse_entered(highlight: TextureRect):
	# Para qualquer tween ativo associado ao highlight
	if active_tweens.has(highlight):
		active_tweens[highlight].kill()  # Para e remove o tween anterior
		active_tweens.erase(highlight)

	# Cria um novo tween e faz o destaque piscar
	var tween = create_tween()
	active_tweens[highlight] = tween  # Armazena o tween associado ao highlight
	tween.tween_property(highlight, "modulate", Color(1, 1, 1, 0.5), 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(highlight, "modulate", Color(1, 1, 1, 0.2), 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(0.1)
	tween.set_loops()

func _on_mouse_exited(highlight: TextureRect):
	# Para o tween ativo e remove o Highlight da lista
	if active_tweens.has(highlight):
		active_tweens[highlight].kill()
		active_tweens.erase(highlight)

	# Retorna o Highlight à transparência total
	var tween = create_tween()
	tween.tween_property(highlight, "modulate", Color(1, 1, 1, 0), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
func equip_item(item_texture: Texture):
	if player and player.has_method("equip_item"):
		player.equip_item(item_texture)  # Notifica o jogador para equipar o item
	else:
		print("⚠️ Jogador ou função equip_item não encontrado!")
		
func add_item(item_scene: PackedScene):
	var item_instance = item_scene.instantiate()
	inventory_items.append(item_instance)

	# Verifica se é o guarda-chuva
	if item_scene == preload("res://Scenes/umbrella.tscn"):  # Substitua pelo caminho correto
		print("☂️ Guarda-chuva adicionado ao inventário.")

func use_item(index: int, player):
	if index >= 0 and index < inventory_items.size():
		var item = inventory_items[index]
		item.use(player)
	else:
		print("Item inválido ou fora do inventário.")
		
func _on_item_slot_pressed(slot_index: int):
	get_parent().use_inventory_item(slot_index)  # Substitua get_parent() pelo nó do jogador
	

func unequip_item(item_texture: Texture):
	if player and player.has_method("unequip_item"):
		player.unequip_item(item_texture)  # Remove os buffs do jogador
	else:
		print("⚠️ Jogador ou função unequip_item não encontrado!")

func _on_hotbar_gui_input(event: InputEvent, slot_index: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		remove_item_from_hotbar()

func remove_item_from_hotbar():
	if hotbar_slots[0] != null:
		var removed_item = hotbar_slots[0]  # Guarda o item que será removido
		
		# Procura o primeiro slot vazio no inventário
		for i in range(num_inventory_slots):
			if inventory_slots[i] == null:
				inventory_slots[i] = removed_item  # Move o item para o inventário
				
				# Atualiza a UI do inventário
				var inventory_slot = container.get_child(i)
				if inventory_slot.has_node("Item"):
					var item_rect = inventory_slot.get_node("Item")
					item_rect.texture = removed_item
					item_rect.visible = true
				
				# Remove o item da hotbar
				hotbar_slots[0] = null
				var hotbar_slot = hotbar_container.get_child(0)
				if hotbar_slot.has_node("Item"):
					var hotbar_item_rect = hotbar_slot.get_node("Item")
					hotbar_item_rect.texture = null
					hotbar_item_rect.visible = false
				
				# Remove os efeitos do item do jogador
				unequip_item(removed_item)

				return  # Para o loop ao encontrar um espaço
