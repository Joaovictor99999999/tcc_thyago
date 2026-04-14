extends CanvasLayer

signal dialogo_finalizado

@onready var texto = $Control/PanelContainer/MarginContainer/Label
@onready var personagem = $Control/TextureRect
@onready var timer = $Control/Timer

var textos: Array = []
var indice = 0

var ativo = false
var escrevendo = false
var pode_avancar = false

func _ready():
	visible = false
	timer.wait_time = 0.03
	process_mode = Node.PROCESS_MODE_ALWAYS

func iniciar_dialogo(lista_textos: Array, textura):
	textos = lista_textos
	indice = 0
	ativo = true
	
	personagem.texture = textura
	
	get_tree().paused = true
	visible = true
	
	mostrar_proximo()

func mostrar_proximo():
	if indice >= textos.size():
		fechar()
		return
	
	pode_avancar = false
	escrevendo = true
	texto.text = ""
	
	var frase = textos[indice]
	indice += 1
	
	escrever_texto(frase)

func escrever_texto(frase: String):
	for letra in frase:
		if not escrevendo:
			break
			
		texto.text += letra
		timer.start()
		await timer.timeout
	
	escrevendo = false
	pode_avancar = true

func _input(_event):
	if not ativo:
		return
	
	if Input.is_action_just_pressed("interact"):
		if escrevendo:
			escrevendo = false 
			texto.text = textos[indice - 1]
			pode_avancar = true
		elif pode_avancar:
			mostrar_proximo()

func fechar():
	ativo = false
	get_tree().paused = false 
	emit_signal("dialogo_finalizado")
	queue_free()
