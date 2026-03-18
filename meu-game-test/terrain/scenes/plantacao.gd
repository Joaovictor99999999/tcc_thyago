extends TileMap

# mapeamento das plantas no sprite sheet
var tiles_para_planta = {

	Vector2i(3,1): "cenoura",
	Vector2i(3,3): "beterraba",
	Vector2i(3,5): "repolho",
	Vector2i(3,7): "alface",
	Vector2i(3,9): "couve_flor",
	Vector2i(3,11): "brocolis",
	Vector2i(3,13): "nabo" # ⚠️ corrigido (tava "napo")

}

# sequência correta da plantação
var sequencia_correta = [
	"cenoura",
	"repolho",
	"beterraba",
	"couve_flor",
	"nabo",
	"brocolis",
	"cenoura",
	"repolho",
	"beterraba",
	"couve_flor"
]

# aqui vão ficar os vetores de cada linha
var linhas = {}


func _ready():
	print("TileMap pronto")
	gerar_vetores()


func gerar_vetores():

	linhas.clear()

	var used_cells = get_used_cells(0)

	print("Células usadas:", used_cells) # 🔥 DEBUG IMPORTANTE

	# ordenar células (importante)
	used_cells.sort_custom(func(a,b):
		if a.y == b.y:
			return a.x < b.x
		return a.y < b.y
	)

	for cell in used_cells:

		var linha = cell.y
		var atlas = get_cell_atlas_coords(0, cell)

		print("Cell:", cell, "Atlas:", atlas) # 🔥 DEBUG INSANO

		if not tiles_para_planta.has(atlas):
			print("Atlas não mapeado:", atlas) # 👈 vai te mostrar o erro real
			continue

		var planta = tiles_para_planta[atlas]

		if not linhas.has(linha):
			linhas[linha] = []

		linhas[linha].append(planta)

	print("Vetores da plantação:")
	print(linhas)
	
	var linhas_ordenadas = linhas.keys()
	linhas_ordenadas.sort()

	for l in linhas_ordenadas:
		print(l, " -> ", linhas[l])


func verificar_linha(linha):

	if not linhas.has(linha):
		return false

	var lista = linhas[linha]

	# evita erro de tamanho diferente
	if lista.size() != sequencia_correta.size():
		return false

	for i in range(lista.size()):
		if lista[i] != sequencia_correta[i]:
			return false

	return true
