extends CanvasLayer

var score: int = 100
var acertos_na_fase: int = 0
var fase_atual: int = 1

# 1. Referências das fichas e telas
# DICA: Se o erro persistir, arraste o nó da aba "Cena" para cá segurando CTRL
@onready var ficha_int = $PainelPrincipal/ficha_int
@onready var ficha_string = $PainelPrincipal/ficha_string
@onready var ficha_float = $PainelPrincipal/ficha_float
@onready var tela_vitoria = $TelaVitoria
@onready var tela_derrota = $TelaDerrota

func _ready() -> void:
	$PainelPrincipal/LabelScore.text = "Score: " + str(score)
	# Aguarda um frame para garantir que tudo carregou
	await get_tree().process_frame
	embaralhar_fichas()

func registrar_erro() -> void:
	score -= 40
	$PainelPrincipal/LabelScore.text = "Score: " + str(score)
	
	if score <= 0:
		score = 0
		$PainelPrincipal/LabelScore.text = "Score: 0"
		var fichas = [ficha_int, ficha_string, ficha_float]
		for f in fichas:
			if is_instance_valid(f):
				f.queue_free()
		tela_derrota.visible = true
		
func registrar_acerto() -> void:
	acertos_na_fase += 1
	if acertos_na_fase == 3:
		verificar_passagem_de_fase()

func verificar_passagem_de_fase() -> void:
	if score >= 70:
		fase_atual += 1
		if fase_atual > 5:
			tela_vitoria.visible = true
		else:
			preparar_nova_fase()
	else:
		tela_derrota.visible = true

func preparar_nova_fase() -> void:
	acertos_na_fase = 0
	var fichas = [ficha_int, ficha_string, ficha_float]
	for f in fichas:
		f.visible = true
		f.aceito_pelo_bau = false 
		f.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Textos das Fases (Ajustados para INT, STRING, FLOAT/BOOL)
	match fase_atual:
		2:
			ficha_int.get_node("Label").text = "99"
			ficha_string.get_node("Label").text = "Minerios"
			ficha_float.get_node("Label").text = "1.5"
		3:
			ficha_int.get_node("Label").text = "-42"
			ficha_string.get_node("Label").text = "Escudo"
			ficha_float.get_node("Label").text = "3.14"
		4:
			ficha_int.get_node("Label").text = "12"
			ficha_string.get_node("Label").text = "Espada"
			ficha_float.get_node("Label").text = "0.7"
		5:
			ficha_int.get_node("Label").text = "67"
			ficha_string.get_node("Label").text = "Ferro"
			ficha_float.get_node("Label").text = "9.99"

	await get_tree().create_timer(0.2).timeout
	embaralhar_fichas()

func embaralhar_fichas() -> void:
	var fichas = [ficha_int, ficha_string, ficha_float]
	
	for f in fichas:
		if is_instance_valid(f):
			f.visible = true
			# Em vez de Vector2 fixo, usamos a posição que já está no Editor
			f.voltar_pro_lugar()
	
# Função para o botão da Tela de Vitória
func _on_botao_vitoria_pressed() -> void:
	# Se o minigame foi instanciado sobre o jogo principal, usamos queue_free()
	# Se você usou SceneTree para mudar de fase, use change_scene_to_file()
	queue_free() 

# Função para o botão da Tela de Derrota (Tentar Novamente)
func _on_botao_retry_pressed() -> void:
	# Reinicia a cena atual do zero
	get_tree().reload_current_scene()
