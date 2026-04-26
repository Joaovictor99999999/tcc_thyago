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
	# 1. Trava de segurança para evitar loops
	if falando: return 
	
	# 2. Verifica a Seta
	var seta = get_tree().get_first_node_in_group("seta_guia")
	if seta and seta.alvo_atual != self:
		exibir_fala_bloqueio()
		return 

	# 3. Diálogo normal (se for o alvo certo)
	falando = true
	interromper_escrita = false
	caixa_dialogo.visible = true
	texto_dialogo.visible = true
	fala_index = 0
	get_tree().paused = true
	proxima_fala()

func exibir_fala_bloqueio():
	falando = true # Ativamos a trava aqui
	
	var dialogo_scene = load("res://minigames/dialogue_box.tscn")
	if not dialogo_scene: 
		falando = false
		return
	
	var instancia = dialogo_scene.instantiate()
	# Definimos uma layer alta para garantir que fique acima de tudo
	if instancia is CanvasLayer:
		instancia.layer = 100
	
	get_tree().current_scene.add_child(instancia)
	get_tree().paused = true
	
	# O SEGREDO: Só liberamos o 'falando = false' depois de um tempinho
	# Isso evita que o 'E' usado para fechar o diálogo reinicie ele na hora
	instancia.connect("dialogo_finalizado", _on_bloqueio_finalizado)
	
	instancia.iniciar_dialogo(
		["Ainda não é hora disso, Murge!", "Siga a seta para saber o que fazer primeiro."],
		preload("res://minigames/game1 (2) (1) (3).png")
	)

func _on_bloqueio_finalizado():
	get_tree().paused = false
	# Aguarda um pequeno instante antes de permitir falar de novo
	await get_tree().create_timer(0.2).timeout
	falando = false

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

# No npc.gd, na função abrir_minigame_direto()
func abrir_minigame_direto():
	if not pode_interagir: return # Trava essencial
	pode_interagir = false 
	
	var jogo = minigame_scene.instantiate()
	get_tree().current_scene.add_child(jogo)
	
	# Isso evita que o clique do 'E' que abriu o jogo 
	# seja lido pelo minigame no mesmo milissegundo
	await get_tree().create_timer(0.2).timeout
	
func bloquear_interacao_temporariamente():
	pode_interagir = false
	await get_tree().create_timer(0.5).timeout
	pode_interagir = true
