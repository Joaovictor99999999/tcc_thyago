extends Area2D

@export var falas: Array[String] = []
@export var minigame_scene: PackedScene
@export var vovo_texture: Texture2D # Para manter o estilo pixel art da conversa

@onready var label_interacao: Label = $LabelInteracao
@onready var caixa_dialogo: PanelContainer = $CanvasLayer/BalaoDialogo
@onready var texto_dialogo: Label = $CanvasLayer/BalaoDialogo/MargensTexto/TextoDialogo
@onready var timer: Timer = $CanvasLayer/Timer

var player_in_area = false
var falando = false
var pode_avancar = false
var fala_index = 0
var pode_interagir = true
var interromper_escrita = false

func _ready() -> void:
	# O NPC precisa processar para detectar o 'E', mas o jogo ainda não está pausado aqui
	process_mode = Node.PROCESS_MODE_ALWAYS 
	caixa_dialogo.visible = false
	texto_dialogo.visible = false
	label_interacao.visible = false
	timer.wait_time = 0.03

func _process(_delta: float) -> void:
	if player_in_area and pode_interagir and Input.is_action_just_pressed("interact"):
		if not falando:
			iniciar_dialogo()
		elif pode_avancar:
			proxima_fala()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Character":
		player_in_area = true
		label_interacao.visible = true
		label_interacao.text = "Pressione 'E' para interagir"

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Character":
		player_in_area = false
		label_interacao.visible = false
		if falando:
			encerrar_dialogo(false) # Fecha sem abrir o minigame se o player fugir

func iniciar_dialogo():
	falando = true
	interromper_escrita = false
	label_interacao.visible = false
	caixa_dialogo.visible = true
	texto_dialogo.visible = true
	fala_index = 0
	
	# Opcional: Pausar o resto do mundo enquanto o NPC fala
	get_tree().paused = true
	
	proxima_fala()

func proxima_fala():
	if fala_index < falas.size():
		pode_avancar = false
		texto_dialogo.text = ""
		var texto = falas[fala_index]
		fala_index += 1
		exibir_texto_gradualmente(texto)
	else:
		encerrar_dialogo(true) # Terminou as falas, abre o jogo

func exibir_texto_gradualmente(texto_completo: String):
	for letra in texto_completo:
		if interromper_escrita: return
		texto_dialogo.text += letra
		timer.start()
		await timer.timeout
	pode_avancar = true

func encerrar_dialogo(abrir_jogo: bool):
	falando = false
	interromper_escrita = true
	caixa_dialogo.visible = false
	texto_dialogo.visible = false
	
	if player_in_area:
		label_interacao.visible = true
	
	# Se terminamos o diálogo naturalmente, chamamos o minigame
	if abrir_jogo and minigame_scene:
		abrir_minigame_direto()
	else:
		# Se apenas fechamos o diálogo (player saiu de perto), despausamos
		get_tree().paused = false

func abrir_minigame_direto():
	var jogo = minigame_scene.instantiate()
	
	# Importante: O minigame deve ser Always para rodar no pause
	jogo.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Adiciona o minigame na cena principal (acima do level)
	get_tree().current_scene.add_child(jogo)
	
	# Desativa o NPC temporariamente para ele não reiniciar o papo
	bloquear_interacao_temporariamente()

func bloquear_interacao_temporariamente():
	pode_interagir = false
	await get_tree().create_timer(0.5).timeout
	pode_interagir = true
