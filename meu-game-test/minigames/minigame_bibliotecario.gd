extends CanvasLayer

var score: int = 100
var acertos_na_fase: int = 0
var fase_atual: int = 1

@onready var ficha_int = $PainelPrincipal/ficha_int
@onready var ficha_string = $PainelPrincipal/ficha_string
@onready var ficha_float = $PainelPrincipal/ficha_float
# Removidos: tela_vitoria e tela_derrota
var conjunto_int: Array = []
var conjunto_string: Array = []
var conjunto_float: Array = []
var finalizado = false
var jogo_liberado = false 
var cutscene_chamada: bool = false
var pos_original_1: Vector2
var pos_original_2: Vector2
var pos_original_3: Vector2

func _ready() -> void:
	pos_original_1 = ficha_int.global_position
	pos_original_2 = ficha_string.global_position
	pos_original_3 = ficha_float.global_position
	process_mode = Node.PROCESS_MODE_ALWAYS
	$PainelPrincipal/TextureRect/LabelScore.text = "Score: " + str(score)
	
	set_fichas_ativas(false)
	iniciar_cutscene()

# --- 🎬 SISTEMA DE DIÁLOGOS (VOVÔ) ---

func iniciar_cutscene():
	if cutscene_chamada: return
	cutscene_chamada = true
	
	var dialogo_scene = load("res://minigames/dialogue_box.tscn")
	if not dialogo_scene: return
	
	var dialogo = dialogo_scene.instantiate()
	dialogo.layer = 100 
	add_child(dialogo)
	
	dialogo.connect("dialogo_finalizado", _on_tutorial_concluido)
	
	dialogo.iniciar_dialogo(
		["Bem-vindo ao minigame de Tipos de Dados!",
		"Na programação, cada valor tem um tipo.",
		"INT (Inteiro), FLOAT (Decimal) e STRING (Texto).",
		"Arraste cada ficha para a caixa correta.",
		"Boa sorte!"],
		preload("res://character/assets/vovo.png")
	)

func _on_tutorial_concluido():
	jogo_liberado = true
	set_fichas_ativas(true)
	embaralhar_fichas()

# --- 🏆 VITÓRIA ---

func iniciar_cutscene_vitoria():
	var dialogo_scene = load("res://minigames/dialogue_box.tscn")
	var dialogo = dialogo_scene.instantiate()
	dialogo.layer = 105
	add_child(dialogo)
	
	dialogo.connect("dialogo_finalizado", _on_fim_do_minigame_vitoria)
	
	dialogo.iniciar_dialogo(
		["Viu só? Você não apenas organizou os livros...",
		"Você criou CONJUNTOS de dados! Cada livro agora guarda apenas um tipo.",
		"Excelente trabalho de organização!.",
		"Nos vemos na proxima, ate mais!"],
		preload("res://character/assets/vovo.png")
	)

func _on_fim_do_minigame_vitoria():
	get_tree().paused = false
	var seta = get_tree().get_first_node_in_group("seta_guia")
	if seta:
		seta.proximo_objetivo()
	queue_free()

# --- ❌ DERROTA (RECOMEÇO AUTOMÁTICO) ---

func iniciar_cutscene_derrota():
	var dialogo_scene = load("res://minigames/dialogue_box.tscn")
	var dialogo = dialogo_scene.instantiate()
	dialogo.layer = 105
	add_child(dialogo)
	
	# Quando o diálogo de erro acabar, chamamos o reset do jogo direto
	dialogo.connect("dialogo_finalizado", _on_botao_retry_pressed)
	
	dialogo.iniciar_dialogo(
		["Oh, não! Os dados ficaram todos bagunçados...",
		"Lembre-se: INT é número inteiro, FLOAT tem ponto e STRING é texto.",
		"Vamos tentar organizar esses dados novamente!"],
		preload("res://character/assets/vovo.png")
	)

# --- 🕹️ LÓGICA DO JOGO ---

func registrar_erro() -> void:
	if finalizado or not jogo_liberado: return
	score -= 40
	if score < 0: score = 0
	$PainelPrincipal/TextureRect/LabelScore.text = "Score: " + str(score)
	if score <= 0: perder_jogo()

func registrar_acerto(tipo: String, valor: String) -> void:
	if finalizado or not jogo_liberado: 
		return
	
	# Adiciona o valor ao conjunto correspondente para o fechamento do jogo
	match tipo:
		"INT": 
			conjunto_int.append(valor)
		"STRING": 
			conjunto_string.append(valor)
		"FLOAT": 
			conjunto_float.append(valor)
	
	acertos_na_fase += 1
	
	# Verifica se todos os 3 tipos da rodada foram organizados
	if acertos_na_fase == 3: 
		verificar_passagem_de_fase()
		

func verificar_passagem_de_fase() -> void:
	if score >= 70:
		if fase_atual >= 5:
			vencer_jogo()
		else:
			# Primeiro o Vovô elogia
			iniciar_cutscene_progresso()
	else:
		perder_jogo()

func executar_sequencia_de_paginas():
	jogo_liberado = false # Trava o clique do jogador
	
	var nomes_baus = ["bau1", "bau2", "bau3"]
	
	for nome in nomes_baus:
		var livro = get_node("PainelPrincipal/" + nome)
		var anim = livro.get_node("AnimationPlayer")
		
		# Reset preventivo: voltamos pro início e limpamos estados anteriores
		anim.stop()
		livro.frame = 0
		
		# Toca a animação
		anim.play("passar_pagina")
		
		# ESPERA PELO SINAL: O código só avança quando a animação emitir 'finished'
		await anim.animation_finished
	
	# Só chega aqui depois que os 3 emitiram o sinal
	fase_atual += 1
	preparar_nova_fase()

func vencer_jogo():
	finalizado = true
	jogo_liberado = false
	set_fichas_ativas(false)
	mostrar_resultado_final()
	

func perder_jogo():
	finalizado = true
	jogo_liberado = false
	set_fichas_ativas(false)
	iniciar_cutscene_derrota()

# --- 🛠️ UTILITÁRIOS E RESET ---

func _on_botao_retry_pressed() -> void:
	score = 100
	acertos_na_fase = 0
	fase_atual = 1
	finalizado = false
	jogo_liberado = true
	$PainelPrincipal/TextureRect/LabelScore.text = "Score: " + str(score)
	atualizar_labels("1", "Papel", "1.0")
	set_fichas_ativas(true)
	embaralhar_fichas()

func set_fichas_ativas(valor: bool):
	var fichas = [ficha_int, ficha_string, ficha_float]
	for f in fichas:
		if is_instance_valid(f):
			f.visible = valor
			f.mouse_filter = Control.MOUSE_FILTER_STOP if valor else Control.MOUSE_FILTER_IGNORE

func preparar_nova_fase() -> void:
	# Reseta visualmente para o frame 0 (aberto)
	for nome in ["bau1", "bau2", "bau3"]:
		var livro = get_node("PainelPrincipal/" + nome)
		livro.frame = 0
		livro.get_node("AnimationPlayer").stop()

	acertos_na_fase = 0
	
	match fase_atual:
		2: atualizar_labels("99", "Dados", "1.5")
		3: atualizar_labels("-42", "Escudo", "3.14")
		4: atualizar_labels("12", "Espada", "0.7")
		5: atualizar_labels("67", "Ferro", "9.99")
	
	set_fichas_ativas(true)
	embaralhar_fichas()
	jogo_liberado = true # Libera o arraste novamente

func atualizar_labels(s_int, s_str, s_float):
	ficha_int.get_node("Label").text = s_int
	ficha_string.get_node("Label").text = s_str
	ficha_float.get_node("Label").text = s_float

func embaralhar_fichas() -> void:
	var fichas = [ficha_int, ficha_string, ficha_float]
	
	# Criamos a lista com as 3 posições salvas
	var posicoes_possiveis = [pos_original_1, pos_original_2, pos_original_3]
	
	# Embaralha a ordem das posições
	posicoes_possiveis.shuffle()
	
	for i in range(fichas.size()):
		var f = fichas[i]
		if is_instance_valid(f):
			# Atribuímos a nova posição sorteada à ficha
			f.posicao_inicial = posicoes_possiveis[i]
			
			# Resetamos a ficha para ela ir para esse novo lugar
			if f.has_method("preparar_nova_rodada"):
				f.preparar_nova_rodada()
			else:
				f.voltar_pro_lugar()
				
func iniciar_cutscene_progresso():
	var dialogo_scene = load("res://minigames/dialogue_box.tscn")
	var dialogo = dialogo_scene.instantiate()
	dialogo.layer = 110
	add_child(dialogo)
	
	# IMPORTANTE: Quando o diálogo fechar, começa a animação das páginas
	dialogo.connect("dialogo_finalizado", executar_sequencia_de_paginas)
	
	var frases = [
		"Isso aí! Você está mandando muito bem!",
		"Boa! Você realmente é bom nisso!",
		"Impressionante, sua lógica está afiada!",
		"Excelente! Vamos para os próximos registros!"
	]
	
	# Pega uma frase aleatória da lista
	var frase_escolhida = frases[randi() % frases.size()]
	
	dialogo.iniciar_dialogo(
		[frase_escolhida],
		preload("res://character/assets/vovo.png")
	)

func mostrar_resultado_final():
	jogo_liberado = false
	$PainelFinal.show() # Um painel que você vai criar com os 3 livros
	
	# Transforma a lista em um texto bonitinho pulando linha (\n)
	# Ex: "99\n12\n67"
	$PainelFinal/LivroInt/Label.text = "\n".join(conjunto_int)
	$PainelFinal/LivroString/Label.text = "\n".join(conjunto_string)
	$PainelFinal/LivroFloat/Label.text = "\n".join(conjunto_float)
	
	# O Vovô aparece uma última vez para explicar
	var dialogo = load("res://minigames/dialogue_box.tscn").instantiate()
	add_child(dialogo)
	dialogo.iniciar_dialogo(
		["Viu só? Você não apenas organizou os livros...",
		"Você criou CONJUNTOS de dados! Cada livro agora guarda apenas um tipo.",
		"Excelente trabalho de organização!"],
		preload("res://character/assets/vovo.png")
	)
	iniciar_cutscene_vitoria()
