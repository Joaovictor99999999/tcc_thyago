extends TextureRect

@export var id_correto: String = "" # ID esperado (ex: "fundacao")
var peca_no_slot: TextureRect = null

# ========================
# 📥 VALIDAÇÃO DO DROP
# ========================
func _can_drop_data(_pos, data):
	return data is Dictionary \
		and data.has("objeto") \
		and data.has("id")

# ========================
# 🎯 AO SOLTAR A PEÇA
# ========================
func _drop_data(_pos, data):
	var nova_peca = data["objeto"]
	var slot_origem = data["slot_origem"]

	# 🚫 Evita dropar a mesma peça no mesmo slot
	if nova_peca == peca_no_slot:
		return

	# 1️⃣ Se já existe uma peça aqui → devolve ela
	if peca_no_slot != null:
		peca_no_slot.voltar_pro_lugar()
		limpar_slot()

	# 2️⃣ Limpa slot de origem corretamente
	if slot_origem != null and slot_origem != self:
		slot_origem.limpar_slot()

	# 3️⃣ Registra nova peça
	peca_no_slot = nova_peca
	nova_peca.ultimo_slot = self
	nova_peca.no_slot = true

	# 4️⃣ Centraliza peça
	nova_peca.mover_para_posicao(global_position, size)

	# 5️⃣ Feedback visual (educacional)
	atualizar_feedback()

# ========================
# 🧹 LIMPAR SLOT
# ========================
func limpar_slot():
	peca_no_slot = null
	resetar_visual()

# ========================
# 🎨 FEEDBACK VISUAL
# ========================
func atualizar_feedback():
	if peca_no_slot == null:
		resetar_visual()
		return

	if peca_no_slot.id_parte == id_correto:
		modulate = Color(0.7, 1.0, 0.7) # verde
	else:
		modulate = Color(1.0, 0.7, 0.7) # vermelho

# ========================
# 🔄 RESET VISUAL
# ========================
func resetar_visual():
	modulate = Color(1, 1, 1)

# ========================
# 🔁 SINCRONIZAÇÃO INICIAL (OPCIONAL)
# ========================
func forcar_sincronizacao():
	limpar_slot()

	for peca in get_tree().get_nodes_in_group("botoes"):
		if peca.global_position.distance_to(global_position) < 30:
			peca_no_slot = peca
			peca.ultimo_slot = self
			peca.no_slot = true
			peca.mover_para_posicao(global_position, size)
			atualizar_feedback()
			break
