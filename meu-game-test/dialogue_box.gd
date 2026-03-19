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
	# IMPORTANTE: Garante que este nó processe inputs mesmo com o jogo pausado
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
	# Limpa o texto antes de começar
	texto.text = ""
	
	for letra in frase:
		# Se o jogador apertou o botão e 'escrevendo' ficou falso, 
		# paramos o loop IMEDIATAMENTE.
		if not escrevendo:
			break
			
		texto.text += letra
		
		# O Timer ajuda a manter a cadência do Pixel Art
		timer.start()
		await timer.timeout
	
	# Garante que, ao sair do loop, o estado esteja correto
	escrevendo = false
	pode_avancar = true

func _input(event):
	if not ativo:
		return
	
	# Verificamos se a ação de interagir foi APERTADA (just_pressed)
	# Usamos a classe global 'Input' para isso, que é mais precisa para UI
	if Input.is_action_just_pressed("interact"):
		
		if escrevendo:
			# 1. Para o loop de escrita
			escrevendo = false 
			# 2. Mostra a frase completa na hora
			# Usamos o indice - 1 porque o mostrar_proximo() já somou +1
			texto.text = textos[indice - 1]
			# 3. Libera o avanço para o PRÓXIMO clique
			pode_avancar = true
			
		elif pode_avancar:
			# Só avança se o texto já estiver estático na tela
			mostrar_proximo()

func fechar():
	ativo = false
	get_tree().paused = false
	
	emit_signal("dialogo_finalizado")
	
	queue_free()
