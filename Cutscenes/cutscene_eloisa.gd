extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var bar1: ColorRect = $CutsceneBar1
@onready var bar2: ColorRect = $CutsceneBar2
@onready var eloisa: Sprite3D = $Eloisa  # Se quiser manipular Eloisa por script

func _ready():
	# As barras começam invisíveis,
	# mas a Eloisa continua aparente no mundo.
	bar1.hide()
	bar2.hide()
	# Se por algum motivo a Eloisa estava oculta, você pode forçar:
	# eloisa.show()

func start_cutscene():
	# Opcionalmente mostrar as barras antes de animar (depende de como você criou suas animações)
	bar1.show()
	bar2.show()

	# 1) "show_bars" anima a entrada das barras pretas
	anim_player.play("show_bars")
	await anim_player.animation_finished

	# 2) "cutscene_eloisa" é a animação principal (Eloisa se movendo etc.)
	anim_player.play("cutscene_eloisa")
	await anim_player.animation_finished

	# 3) "hide_bars" anima as barras saindo
	anim_player.play("hide_bars")
	await anim_player.animation_finished

	# 4) Finaliza a cutscene
	end_cutscene()

func end_cutscene():
	# No final, se você quiser de fato remover as barras da tela, esconda-as.
	bar1.hide()
	bar2.hide()

	# Se quiser reabilitar input do player (caso tenha bloqueado):
	# var player = get_tree().get_root().get_node("CAMINHO/DO/PLAYER")
	# player.input_enabled = true

	# Não chamamos hide() no Node3D inteiro, pois queremos que a Eloisa siga visível.
