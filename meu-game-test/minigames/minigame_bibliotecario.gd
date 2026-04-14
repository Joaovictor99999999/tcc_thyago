extends CanvasLayer

var score: int = 100
var acertos_na_fase: int = 0
var fase_atual: int = 1

@onready var ficha_int = $PainelPrincipal/ficha_int
@onready var ficha_string = $PainelPrincipal/ficha_string
@onready var ficha_float = $PainelPrincipal/ficha_float
# Removidos: tela_vitoria e tela_derrota

var finalizado = false
var jogo_liberado = false 
var cutscene_chamada: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$PainelPrincipal/LabelScore.text = "Score: " + str(score)
	
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
		["Excelente trabalho!",
		"Você classificou todos os tipos de dados corretamente.",
		"A ponte está um passo mais perto de ficar pronta!",
		"Até a próxima!"],
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
	$PainelPrincipal/LabelScore.text = "Score: " + str(score)
	if score <= 0: perder_jogo()

func registrar_acerto() -> void:
	if finalizado or not jogo_liberado: return
	acertos_na_fase += 1
	if acertos_na_fase == 3: verificar_passagem_de_fase()

func verificar_passagem_de_fase() -> void:
	if score >= 70:
		if fase_atual >= 5:
			vencer_jogo()
		else:
			fase_atual += 1
			preparar_nova_fase()
	else:
		perder_jogo()

func vencer_jogo():
	finalizado = true
	jogo_liberado = false
	set_fichas_ativas(false)
	iniciar_cutscene_vitoria()

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
	$PainelPrincipal/LabelScore.text = "Score: " + str(score)
	atualizar_labels("1", "Texto", "1.0")
	set_fichas_ativas(true)
	embaralhar_fichas()

func set_fichas_ativas(valor: bool):
	var fichas = [ficha_int, ficha_string, ficha_float]
	for f in fichas:
		if is_instance_valid(f):
			f.visible = valor
			f.mouse_filter = Control.MOUSE_FILTER_STOP if valor else Control.MOUSE_FILTER_IGNORE

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
	ficha_int.get_node("Label").text = s_int
	ficha_string.get_node("Label").text = s_str
	ficha_float.get_node("Label").text = s_float

func embaralhar_fichas() -> void:
	var fichas = [ficha_int, ficha_string, ficha_float]
	for f in fichas:
		if is_instance_valid(f):
			f.aceito_pelo_bau = false 
			f.voltar_pro_lugar()
