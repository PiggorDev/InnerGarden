extends Control

@onready var pause_overlay = $PauseRect
@onready var pause_label = $Label

var is_paused = false

func _ready():
	pause_overlay.visible = false
	pause_label.visible = false
	pause_overlay.color = Color(0, 0, 0, 0.7)  # Define a transparência da tela escura

func _unhandled_input(event):
	if event.is_action_pressed("ui_pause"):  # Enter ou tecla configurada para pausar
		toggle_pause()
		get_viewport().set_input_as_handled()  # Impede que o input passe para outras cenas

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused  # Alterna o estado do jogo

	pause_overlay.visible = is_paused
	pause_label.visible = is_paused

	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Mostra o cursor
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # Esconde o cursor
