extends Area2D

@export var falas: Array[String] = []
@export var minigame_scene: PackedScene
@onready var label_interacao: Label = $LabelInteracao
@onready var caixa_dialogo: PanelContainer = $CanvasLayer/BalaoDialogo
@onready var texto_dialogo: Label = $CanvasLayer/BalaoDialogo/MargensTexto/TextoDialogo
@onready var timer: Timer = $CanvasLayer/Timer

var player_in_area = false
var falando = false
var pode_avancar = false
var fala_index = 0


func _ready() -> void:
	caixa_dialogo.visible = false
	texto_dialogo.visible = false
	label_interacao.visible = false
	timer.wait_time = 0.03


func _process(_delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("interact"):
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
			encerrar_dialogo()

func abrir_minigame():
	if minigame_scene:
		var instancia = minigame_scene.instantiate()
		get_tree().current_scene.add_child(instancia)

		get_tree().paused = true
		
func iniciar_dialogo():
	falando = true
	label_interacao.visible = false
	caixa_dialogo.visible = true
	texto_dialogo.visible = true
	fala_index = 0
	proxima_fala()


func proxima_fala():
	if fala_index < falas.size():
		pode_avancar = false
		texto_dialogo.text = ""
		var texto = falas[fala_index]
		fala_index += 1
		exibir_texto_gradualmente(texto)
	else:
		encerrar_dialogo()


func exibir_texto_gradualmente(texto_completo: String):
	for letra in texto_completo:
		texto_dialogo.text += letra
		timer.start()
		await timer.timeout
	pode_avancar = true


func encerrar_dialogo():
	falando = false
	caixa_dialogo.visible = false
	texto_dialogo.visible = false
	
	if player_in_area:
		label_interacao.visible = true
	
	abrir_minigame()
