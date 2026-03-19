extends CanvasLayer

var score: int = 100
var acertos_na_fase: int = 0
var fase_atual: int = 1

@onready var ficha_int = $PainelPrincipal/ficha_int
@onready var ficha_string = $PainelPrincipal/ficha_string
@onready var ficha_float = $PainelPrincipal/ficha_float
@onready var tela_vitoria = $TelaVitoria
@onready var tela_derrota = $TelaDerrota

var finalizado = false
var jogo_liberado = false 

func _ready() -> void:
	# 1. Garante funcionamento independente do pause do mundo
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	$PainelPrincipal/LabelScore.text = "Score: " + str(score)
	
	# Reset visual inicial
	set_fichas_ativas(false)
	tela_vitoria.visible = false
	tela_derrota.visible = false
	
	# Inicia a explicação (Vovô)
	iniciar_cutscene()

func set_fichas_ativas(valor: bool):
	var fichas = [ficha_int, ficha_string, ficha_float]
	for f in fichas:
		if is_instance_valid(f):
			f.visible = valor
			# Importante para o Pixel Art: garantir que não sumam por erro de visibilidade
			f.mouse_filter = Control.MOUSE_FILTER_STOP if valor else Control.MOUSE_FILTER_IGNORE

func registrar_erro() -> void:
	if finalizado or not jogo_liberado: return

	score -= 40
	if score < 0: score = 0
	$PainelPrincipal/LabelScore.text = "Score: " + str(score)

	if score <= 0:
		perder_jogo()

func registrar_acerto() -> void:
	if finalizado or not jogo_liberado: return
	
	acertos_na_fase += 1
	if acertos_na_fase == 3:
		verificar_passagem_de_fase()

func verificar_passagem_de_fase() -> void:
	if score >= 70:
		if fase_atual >= 5:
			vencer_jogo()
		else:
			fase_atual += 1
			preparar_nova_fase()
	else:
		perder_jogo()

func preparar_nova_fase() -> void:
	acertos_na_fase = 0
	
	match fase_atual:
		2: atualizar_labels("99", "Minerios", "1.5")
		3: atualizar_labels("-42", "Escudo", "3.14")
		4: atualizar_labels("12", "Espada", "0.7")
		5: atualizar_labels("67", "Ferro", "9.99")

	set_fichas_ativas(true)
	embaralhar_fichas()

func atualizar_labels(s_int, s_str, s_float):
	# Dica: Verifique se esses labels existem nas suas cenas de Pixel Art
	ficha_int.get_node("Label").text = s_int
	ficha_string.get_node("Label").text = s_str
	ficha_float.get_node("Label").text = s_float

func embaralhar_fichas() -> void:
	var fichas = [ficha_int, ficha_string, ficha_float]
	for f in fichas:
		if is_instance_valid(f):
			f.aceito_pelo_bau = false 
			f.voltar_pro_lugar()

func iniciar_cutscene():
	var dialogo_scene = load("res://minigames/dialogue_box.tscn")
	if not dialogo_scene: return
	
	var dialogo = dialogo_scene.instantiate()
	
	# GARANTIA 1: Forçamos o Diálogo a aparecer na frente de tudo via código
	dialogo.layer = 100 
	dialogo.process_mode = Node.PROCESS_MODE_ALWAYS
	
	add_child(dialogo)
	
	# GARANTIA 2: Verificamos se o nó Control do diálogo está visível
	dialogo.visible = true 

	dialogo.connect("dialogo_finalizado", _on_tutorial_concluido)
	
	dialogo.iniciar_dialogo(
		["Explicação do jogo..."],
		preload("res://character/assets/vovo.png")
	)

func _on_tutorial_concluido():
	jogo_liberado = true
	set_fichas_ativas(true)
	embaralhar_fichas()

func vencer_jogo():
	finalizado = true
	jogo_liberado = false
	set_fichas_ativas(false)
	tela_vitoria.visible = true

func perder_jogo():
	finalizado = true
	jogo_liberado = false
	
	# Deixa as fichas invisíveis na hora
	ficha_int.visible = false
	ficha_string.visible = false
	ficha_float.visible = false
	
	# Mostra a tela de derrota
	tela_derrota.visible = true
	tela_derrota.z_index = 100

func reiniciar_minigame():
	# 1. Reseta os dados básicos
	score = 100
	acertos_na_fase = 0
	fase_atual = 1
	finalizado = false
	jogo_liberado = false
	
	# 2. Atualiza a interface
	$PainelPrincipal/LabelScore.text = "Score: " + str(score)
	tela_derrota.visible = false
	tela_vitoria.visible = false
	
	# 3. Reseta os textos das fichas para o estado inicial (Fase 1)
	atualizar_labels("1", "Texto", "1.0") 
	
	# 4. Faz as fichas voltarem e embaralha
	set_fichas_ativas(true)
	embaralhar_fichas()
	
	# 5. Opcional: Se quiser que o Vovô explique de novo, chame iniciar_cutscene()
	# Se preferir que o jogo comece direto, apenas libere:
	jogo_liberado = true

func finalizar_jogo():
	# ESSA É A PARTE MAIS IMPORTANTE:
	# Como o NPC deu pause, o Minigame precisa despausar antes de sumir
	get_tree().paused = false
	queue_free()
	
	# --- BOTÃO DE TENTAR NOVAMENTE (TELA DE DERROTA) ---
func _on_botao_retry_pressed() -> void:
	# 1. Resetar os pontos (MUITO IMPORTANTE para não morrer de primeira)
	score = 100
	acertos_na_fase = 0
	fase_atual = 1
	finalizado = false
	jogo_liberado = true
	
	# 2. Atualizar o texto do placar na tela
	$PainelPrincipal/LabelScore.text = "Score: " + str(score)
	
	# 3. Voltar os textos das fichas para a Fase 1
	ficha_int.get_node("Label").text = "1"
	ficha_string.get_node("Label").text = "Texto"
	ficha_float.get_node("Label").text = "1.0"
	
	# 4. Deixar as fichas visíveis e interativas de novo
	ficha_int.visible = true
	ficha_string.visible = true
	ficha_float.visible = true
	
	ficha_int.mouse_filter = Control.MOUSE_FILTER_STOP
	ficha_string.mouse_filter = Control.MOUSE_FILTER_STOP
	ficha_float.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 5. Organizar a mesa e sumir com a tela de derrota
	embaralhar_fichas()
	tela_derrota.visible = false
	
# --- BOTÃO DE COLETAR / GANHAR (TELA DE VITÓRIA) ---
func _on_botao_coletar_pressed() -> void:
	# 1. Libera o pause do mundo para o player voltar a andar
	get_tree().paused = false
	
	# 2. Fecha o minigame
	queue_free()
