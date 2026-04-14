extends TileMap

# 🥕 Mapeamento (Sempre verifique se as coordenadas no seu Atlas batem aqui)
var tiles_para_planta = {
	Vector2i(3,1): "cenoura",
	Vector2i(3,3): "beterraba",
	Vector2i(3,5): "repolho",
	Vector2i(3,7): "alface",
	Vector2i(3,9): "couve_flor",
	Vector2i(3,11): "brocolis",
	Vector2i(3,13): "nabo"
}

# 📋 O Gabarito do Vovô (Agora com 7 itens, para as 7 colunas/índices)
var sequencia_correta = [
	"cenoura", "repolho", "beterraba", "alface", "couve_flor", "brocolis", "nabo"
]

# Armazena o estado atual da plantação
var vetor_atual = []

func _ready():
	print("Vetor de plantas pronto para organizar!")
	atualizar_vetor_logico()

# 📝 Esta função lê o TileMap e transforma em uma lista de nomes (Vetor)
func atualizar_vetor_logico():
	vetor_atual.clear()
	
	# Vamos ler apenas a linha de plantio (ex: linha Y = 1)
	# E percorrer as colunas de 0 a 6 (nossos 7 índices)
	for i in range(7):
		var cell = Vector2i(i, 1) # i é o índice (X), 1 é a fileira (Y)
		var atlas = get_cell_atlas_coords(0, cell)
		
		if tiles_para_planta.has(atlas):
			vetor_atual.append(tiles_para_planta[atlas])
		else:
			vetor_atual.append("vazio") # Representa o null/vazio no vetor
	
	print("Estado do Vetor no Chão: ", vetor_atual)

# ✅ Função de Verificação de Vitória
func verificar_vitoria() -> bool:
	atualizar_vetor_logico() # Primeiro lê o que está no chão
	
	# Compara o tamanho (Prevenção de erros)
	if vetor_atual.size() != sequencia_correta.size():
		return false
	
	# Compara item por item (Vetor A == Vetor B?)
	for i in range(vetor_atual.size()):
		if vetor_atual[i] != sequencia_correta[i]:
			return false
	
	return true # Se chegou aqui, os vetores são idênticos!
