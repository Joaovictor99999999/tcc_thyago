extends Node2D

@onready var plantacao = $UI/Plantacao

var primeira_planta = null

# 🧠 NOVAS VARIÁVEIS (vetor)
var celula_selecionada = null
var modo_adicionar = false
var planta_para_adicionar = null

# 🌱 mapeamento planta → atlas
var planta_para_tile = {
	"cenoura": Vector2i(4,1),
	"beterraba": Vector2i(4,3),
	"repolho": Vector2i(4,5),
	"alface": Vector2i(4,7),
	"couve_flor": Vector2i(4,9),
	"brocolis": Vector2i(4,11),
	"nabo": Vector2i(4,13)
}


func _ready():
	print("Mini game iniciou")
	copiar_plantacao()


func _unhandled_input(event):

	if event is InputEventMouseButton and event.pressed:

		print("\n========================")
		print("CLIQUE DETECTADO")

		# ✅ CORREÇÃO REAL (ESSA AQUI RESOLVEU TUDO)
		var cell = plantacao.local_to_map(plantacao.get_local_mouse_position())

		print("Cell clicada:", cell)

		var usadas = plantacao.get_used_cells(0)

		# 🔥 MODO ADICIONAR
		if modo_adicionar:
			adicionar_planta(cell)
			modo_adicionar = false
			return

		# 👉 SE NÃO TEM PLANTA → ignora
		if not usadas.has(cell):
			print("Nenhuma planta aqui")
			return

		print("Planta encontrada")

		# 🧠 seleção estilo vetor
		celula_selecionada = cell

		var linha = cell.y
		var indice = cell.x

		print("Selecionado vetor:", linha, "indice:", indice)

		# 🔁 SISTEMA DE TROCA
		if primeira_planta == null:
			primeira_planta = cell
		else:
			trocar_plantas(primeira_planta, cell)
			primeira_planta = null


func trocar_plantas(c1, c2):

	print("Trocando plantas")

	# 🔥 evita bug após remover
	if not plantacao.get_used_cells(0).has(c1):
		print("Primeira planta inválida!")
		primeira_planta = null
		return

	var source1 = plantacao.get_cell_source_id(0, c1)
	var atlas1 = plantacao.get_cell_atlas_coords(0, c1)

	var source2 = plantacao.get_cell_source_id(0, c2)
	var atlas2 = plantacao.get_cell_atlas_coords(0, c2)

	plantacao.set_cell(0, c1, source2, atlas2)
	plantacao.set_cell(0, c2, source1, atlas1)


# ➖ REMOVER
func remover_planta():

	if celula_selecionada == null:
		print("Nada selecionado")
		return

	print("Removendo:", celula_selecionada)

	plantacao.set_cell(0, celula_selecionada, -1)

	# 🔥 CORREÇÃO DO BUG QUE VOCÊ FALOU
	celula_selecionada = null
	primeira_planta = null


# ➕ INICIAR ADIÇÃO
func iniciar_adicionar(nome_planta):

	modo_adicionar = true
	planta_para_adicionar = nome_planta

	print("Modo adicionar:", nome_planta)


# ➕ ADICIONAR
func adicionar_planta(cell):

	if planta_para_adicionar == null:
		return

	if not planta_para_tile.has(planta_para_adicionar):
		print("Erro: planta não existe")
		return

	var atlas = planta_para_tile[planta_para_adicionar]
	var source_id = 1

	print("Adicionando:", planta_para_adicionar, "em", cell)

	plantacao.set_cell(1, cell, source_id, atlas)

	planta_para_adicionar = null


func copiar_plantacao():

	var original = get_tree().get_first_node_in_group("plantacao")

	if original == null:
		print("Plantacao não encontrada")
		return

	var cells = original.get_used_cells(0)

	for cell in cells:

		var atlas = original.get_cell_atlas_coords(0, cell)
		var source = original.get_cell_source_id(0, cell)

		plantacao.set_cell(0, cell, source, atlas)


func _on_voltar_pressed() -> void:
	get_tree().paused = false
	queue_free()
	
func _on_remover_pressed():
	remover_planta()

func _on_add_cenoura_pressed():
	iniciar_adicionar("cenoura")

func _on_add_repolho_pressed():
	iniciar_adicionar("repolho")
	
func _on_add_beterraba_pressed():
	iniciar_adicionar("beterraba")
	
func _on_add_alface_pressed():
	iniciar_adicionar("alface")
	
func _on_add_couve_flor_pressed():
	iniciar_adicionar("couve_flor")
	
func _on_add_brocolis_pressed():
	iniciar_adicionar("brocolis")
	
func _on_add_napo_pressed():
	iniciar_adicionar("napo")
