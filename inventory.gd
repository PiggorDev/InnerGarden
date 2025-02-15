extends CanvasLayer

@onready var overlay = $InventoryOverlay
@onready var slots = [
	$"Slot container/Slot1",
	$"Slot container/Slot2",
	$"Slot container/Slot3",
	$"Slot container/Slot4"
]
@onready var small_inventory_slot = $HotBar  # Referência à hotbar
var inventory_data: Array = [null, null, null, null]  # Dados dos slots do inventário

# Dicionário de sprites dos itens
var item_sprites = {
	"umbrella": preload("res://Sprites/Inventory/UmbrellaBIG.png")
}

func _ready():
	# Configurar slots com botões invisíveis e z-index
	for i in range(slots.size()):
		var button = Button.new()
		button.name = "SlotButton"
		button.modulate = Color(1, 1, 1, 0)  # Botão invisível
		button.z_index = 0  # Abaixo do efeito de hover
		button.mouse_filter = Control.MOUSE_FILTER_PASS  # Não bloqueia hover
		button.connect("pressed", Callable(self, "_on_slot_clicked").bind(i))  # Conecta ao clique
		slots[i].add_child(button)

	# Configurar hover visual
	for slot in slots:
		slot.z_index = 1  # Prioridade de exibição dos slots
	overlay.visible = false  # Começa invisível

# Atualiza a exibição do inventário
func update_inventory_display():
	for i in range(slots.size()):
		if inventory_data[i] != null and inventory_data[i] in item_sprites:
			if not slots[i].has_node("OverlayIcon"):
				var overlay_icon = TextureRect.new()
				overlay_icon.name = "OverlayIcon"
				overlay_icon.texture = item_sprites[inventory_data[i]]
				overlay_icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
				overlay_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				slots[i].add_child(overlay_icon)
		else:
			if slots[i].has_node("OverlayIcon"):
				slots[i].get_node("OverlayIcon").queue_free()

# Mostra o inventário
func show_inventory():
	overlay.visible = true
	for slot in slots:
		slot.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Esconde o inventário
func hide_inventory():
	overlay.visible = false
	for slot in slots:
		slot.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Clique no slot
func _on_slot_clicked(slot_index):
	if inventory_data[slot_index] != null:
		var item_name = inventory_data[slot_index]
		if item_name == "umbrella":
			equip_item(item_name)
			inventory_data[slot_index] = null
			if slots[slot_index].has_node("OverlayIcon"):
				slots[slot_index].get_node("OverlayIcon").queue_free()
			update_inventory_display()
			print("✅ Guarda-chuva movido para a Hotbar!")
		else:
			print("⚠️ Item não equipável.")
	else:
		print("⚠️ Slot vazio.")

# Adiciona item ao inventário
func add_item_to_inventory(item_name: String):
	for i in range(inventory_data.size()):
		if inventory_data[i] == null:
			inventory_data[i] = item_name
			update_inventory_display()
			return
	print("❌ Inventário cheio.")

# Equipa um item na hotbar
func equip_item(item_name: String):
	if item_name in item_sprites:
		small_inventory_slot.texture = item_sprites[item_name]
		print("☂️ {item_name.capitalize()} equipado na Hotbar!")
	else:
		print("❌ Sprite do item {item_name} não encontrado.")
