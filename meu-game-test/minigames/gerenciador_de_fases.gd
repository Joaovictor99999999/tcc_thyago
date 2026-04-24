extends Node

var fase_atual = 0
var dialogo_ativo = false

# 🧩 GABARITO DAS FASES
var fases = [
	["1", "2", "3"],
	["1", "2", "3"],
	["1", "2", "3"],
	["1", "2", "3"]
]

var nomes_fases = ["Macro", "Fundacao", "Estrutura", "Finalizacao"]

func _ready():
	add_to_group("gerenciador_fase")
	atualizar_visibilidade_fases()

# ========================
# 🎯 VERIFICAÇÃO PRINCIPAL
# ========================
func verificar_resposta():
	print("🟡 verificar_resposta FOI CHAMADA")

	if dialogo_ativo:
		print("⛔ BLOQUEADO POR DIALOGO")
		return
	
	print("➡️ Indo pegar slots...")
	var slots = pegar_slots_ordenados()
	print("Slots encontrados:", slots.size())

	print("➡️ Coletando ordem...")
	var ordem_jogador = coletar_ordem(slots)
	print("Ordem jogador:", ordem_jogador)
	print("Gabarito:", fases[fase_atual])

	if ordem_jogador == fases[fase_atual]:
		print("✅ ACERTOU")
		exibir_vitoria()
	else:
		print("❌ ERROU")
		destacar_erros(slots, ordem_jogador)
		exibir_erro(ordem_jogador)

# ========================
# 📦 PEGAR SLOTS ORDENADOS
# ========================
func pegar_slots_ordenados():
	var grupo_atual = nomes_fases[fase_atual]
	var slots = get_tree().get_nodes_in_group(grupo_atual)

	# Segurança: só ordena se tiver índice
	if slots.size() > 0 and "indice" in slots[0]:
		slots.sort_custom(func(a, b): return a.indice < b.indice)

	return slots

# ========================
# 📥 COLETAR ORDEM
# ========================
func coletar_ordem(slots):
	var ordem: Array[String] = []

	for slot in slots:
		if slot.peca_no_slot:
			ordem.append(slot.peca_no_slot.id_parte)
		else:
			ordem.append("vazio")

	return ordem

# ========================
# ❌ DESTACAR ERROS (VISUAL)
# ========================
func destacar_erros(slots, ordem_jogador):
	for i in range(slots.size()):
		var slot = slots[i]

		if ordem_jogador[i] != fases[fase_atual][i]:
			slot.modulate = Color(1, 0.5, 0.5) # vermelho forte
		else:
			slot.modulate = Color(0.5, 1, 0.5) # verde

# ========================
# ❌ LÓGICA DE ERRO
# ========================
func exibir_erro(ordem_jogador: Array):
	for i in range(ordem_jogador.size()):
		if ordem_jogador[i] != fases[fase_atual][i]:
			var posicao = str(i + 1)
			var frase = "A peça na posição " + posicao + " não parece certa. Revise o plano!"
			criar_dialogo([frase])
			return

# ========================
# ✅ VITÓRIA
# ========================
func exibir_vitoria():
	var frases = [
		"Excelente! A fase " + nomes_fases[fase_atual] + " está concluída!",
		"Próxima etapa!"
	]

	criar_dialogo(frases, avancar_fase)

# ========================
# ⏭️ AVANÇAR FASE
# ========================
func avancar_fase():
	fase_atual += 1

	if fase_atual >= fases.size():
		finalizar_jogo()
	else:
		atualizar_visibilidade_fases()

# ========================
# 🎬 VISIBILIDADE DAS FASES
# ========================
func atualizar_visibilidade_fases():
	var fases_node = get_tree().get_first_node_in_group("fases")
	if not fases_node:
		return
	
	for f in fases_node.get_children():
		f.visible = (f.name == nomes_fases[fase_atual])

	# Espera UI estabilizar
	await get_tree().process_frame
	await get_tree().process_frame

	resetar_slots()

# ========================
# 🔄 RESET DOS SLOTS
# ========================
func resetar_slots():
	for slot in get_tree().get_nodes_in_group(nomes_fases[fase_atual]):
		if slot.has_method("limpar_slot"):
			slot.limpar_slot()

# ========================
# 💬 DIÁLOGO
# ========================
func criar_dialogo(frases: Array, callback: Callable = Callable()):
	var dialogo_scene = load("res://minigames/dialogue_box.tscn")
	var dialogo = dialogo_scene.instantiate()
	add_child(dialogo)

	dialogo_ativo = true

	if callback.is_valid():
		dialogo.connect("dialogo_finalizado", callback)

	dialogo.connect("dialogo_finalizado", func():
		dialogo_ativo = false
		print("Dialogo finalizado!")
)

	dialogo.iniciar_dialogo(frases, preload("res://character/assets/vovo.png"))

# ========================
# 🏁 FINAL DO JOGO
# ========================
func finalizar_jogo():
	# Criamos o diálogo passando a função '_concluir_e_fechar' como callback
	# Assim, o código dentro de '_concluir_e_fechar' só roda quando o diálogo terminar.
	criar_dialogo(
		["Ponte finalizada! Você é um mestre da decomposição!"], 
		_concluir_e_fechar
	)

# Esta função só será chamada quando o sinal "dialogo_finalizado" for emitido
func _concluir_e_fechar():
	print("🏆 Minigame encerrado, voltando para a vila...")
	get_tree().paused = false
	
	# Se o script está em um filho, owner deleta a cena inteira instanciada
	if owner:
		owner.queue_free()
	else:
		queue_free()
