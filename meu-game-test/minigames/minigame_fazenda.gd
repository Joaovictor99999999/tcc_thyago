extends CanvasLayer # MUDADO: Agora o script e o nó no editor devem ser CanvasLayer

# --- REFERÊNCIAS AOS NÓS (Unique Name %) ---
@onready var plantacao = %Plantacao
@onready var label_indice_topo = %LabelIndice
@onready var label_indice_alvo = %LabelIndiceAlvo
@onready var texto_instrucao = %TextoInstrucao
@onready var label_coluna_alvo = %LabelColunaAlvo 

# --- VARIÁVEIS DE CONTROLE ---
var indice_selecionado: int = 0
var coluna_selecionada: int = 0
var semente_na_mao: String = ""
var MAX_COLUNAS = 6
var cutscene_chamada: bool = false

# 🌱 MAPEAMENTO (Planta -> Coordenada no seu Atlas)
var planta_para_tile = {
	"cenoura": Vector2i(4,1),
	"beterraba": Vector2i(4,3),
	"repolho": Vector2i(4,5),
	"alface": Vector2i(4,7),
	"couve_flor": Vector2i(4,9),
	"brocolis": Vector2i(4,11),
	"nabo": Vector2i(4,13)
}

# 🗺️ MAPA DA HORTA
var mapa_horta = {
	0: [Vector2i(-12, 4), 4], 
	1: [Vector2i(-10, 6), 8],
	2: [Vector2i(-8, 6), 8],
	3: [Vector2i(-6, 6), 8],
	4: [Vector2i(-4, 4), 4],
	5: [Vector2i(-2, 4), 7],
	6: [Vector2i(0, 4), 7]
}

var objetivo_horta = {
	0: "repolho",
	1: "nabo",
	2: "couve_flor",
	3: "cenoura",
	4: "brocolis",
	5: "beterraba",
	6: "alface"
}

func _ready():
	# Garante que o minigame processe mesmo se o jogo estiver pausado no fundo
	process_mode = Node.PROCESS_MODE_ALWAYS 
	atualizar_ui()
	iniciar_cutscene()

# --- 🎬 LÓGICA DA CUTSCENE ---

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
		["Olá, olhe para esta horta...",
		"Cada fileira de terra funciona como um VETOR (Array).",
		"Um VETOR é uma lista que guarda várias informações em uma única variável.",
		"Para encontrar uma planta, usamos o ÍNDICE, que é a posição dela na lista.",
		"O primeiro lugar da lista é sempre o ÍNDICE 0!",
		"Como temos várias fileiras, criamos uma MATRIZ.",
		"Uma MATRIZ é basicamente uma lista de listas, como um mapa de coordenadas.",
		"Use as setas para definir o endereço exato [Coluna][Índice]...",
		"E plante o tipo de dado correto em cada buraco!"],
		preload("res://character/assets/fazendeiro.png")
	)

func _on_tutorial_concluido():
	texto_instrucao.text = "O Vovô explicou tudo! Pode começar a plantar."

# --- 🕹️ NAVEGAÇÃO E AÇÕES ---

func _on_botao_indice_esq_pressed():
	if indice_selecionado > 0:
		indice_selecionado -= 1
		atualizar_ui()

func _on_botao_indice_dir_pressed():
	var limite_desta_coluna = mapa_horta[coluna_selecionada][1]
	if indice_selecionado < limite_desta_coluna:
		indice_selecionado += 1
		atualizar_ui()

func _on_botao_coluna_esq_pressed():
	if coluna_selecionada > 0:
		coluna_selecionada -= 1
		indice_selecionado = 0
		atualizar_ui()

func _on_botao_coluna_dir_pressed():
	if coluna_selecionada < MAX_COLUNAS:
		coluna_selecionada += 1
		indice_selecionado = 0
		atualizar_ui()

func atualizar_ui():
	label_indice_alvo.text = str(indice_selecionado)
	label_coluna_alvo.text = str(coluna_selecionada)
	texto_instrucao.text = "Endereço: [%d][%d]" % [coluna_selecionada, indice_selecionado]

func selecionar_semente(nome_planta: String):
	semente_na_mao = nome_planta
	texto_instrucao.text = nome_planta.capitalize() + " na mão!"

func _on_add_cenoura_pressed(): selecionar_semente("cenoura")
func _on_add_repolho_pressed(): selecionar_semente("repolho")
func _on_add_beterraba_pressed(): selecionar_semente("beterraba")
func _on_add_alface_pressed(): selecionar_semente("alface")
func _on_add_couve_flor_pressed(): selecionar_semente("couve_flor")
func _on_add_brocolis_pressed(): selecionar_semente("brocolis")
func _on_add_nabo_pressed(): selecionar_semente("nabo")

func calcular_posicao_grade() -> Vector2i:
	var dados_coluna = mapa_horta[coluna_selecionada]
	var ponto_inicial = dados_coluna[0]
	return Vector2i(ponto_inicial.x, ponto_inicial.y - indice_selecionado)

func _on_botao_plantar_pressed():
	if semente_na_mao == "":
		texto_instrucao.text = "Selecione uma semente!"
		return
	
	var cell_alvo = calcular_posicao_grade()
	var atlas_coords = planta_para_tile[semente_na_mao]
	plantacao.set_cell(0, cell_alvo, 1, atlas_coords)
	verificar_vitoria()

func _on_remover_pressed():
	var cell_alvo = calcular_posicao_grade()
	plantacao.set_cell(0, cell_alvo, -1)

func verificar_vitoria():
	for col in objetivo_horta.keys():
		var legume_correto = objetivo_horta[col]
		var atlas_esperado = planta_para_tile[legume_correto]
		var ponto_inicial = mapa_horta[col][0]
		var limite_linhas = mapa_horta[col][1]
		
		for i in range(limite_linhas + 1):
			var pos_grid = Vector2i(ponto_inicial.x, ponto_inicial.y - i)
			var id_atual = plantacao.get_cell_source_id(0, pos_grid)
			var atlas_atual = plantacao.get_cell_atlas_coords(0, pos_grid)
			
			if id_atual != 1 or atlas_atual != atlas_esperado:
				return 

	ganhou_jogo()

func ganhou_jogo():
	texto_instrucao.text = "🎉 VITÓRIA!"
	var dialogo_scene = load("res://minigames/dialogue_box.tscn")
	var dialogo = dialogo_scene.instantiate()
	add_child(dialogo)
	dialogo.connect("dialogo_finalizado", _on_fim_do_jogo_total)
	
	dialogo.iniciar_dialogo(
		["Incrível! Você organizou toda a matriz de dados.",
		"Agora a fazenda está rodando sem bugs!",
		"Até a próxima!"],
		preload("res://character/assets/fazendeiro.png")
	)

# --- 🏁 A SOLUÇÃO FINAL ---
func _on_fim_do_jogo_total():
	get_tree().paused = false
	var seta = get_tree().get_first_node_in_group("seta_guia")
	if seta:
		seta.proximo_objetivo()
	queue_free() # Deleta o minigame, mas a seta sobrevive no Player
