extends Area2D

@export var lista_npcs: Array[Area2D] = [] 
var alvo_atual: Area2D = null

func _ready():
	add_to_group("seta_guia")
	atualizar_alvo()

func _process(_delta):
	# 1. Se não tem alvo, ela morre aqui.
	if not alvo_atual:
		visible = false
		return

	# 2. Atualiza a física (posição e mira)
	position = Vector2(14, -50) 
	look_at(alvo_atual.global_position)
	
	# 3. A DECISÃO FINAL:
	# Chamamos a função e deixamos ELA decidir o visible, 
	# sem nada depois dela para sobrescrever.
	verificar_sobreposicao()

func verificar_sobreposicao():
	var esta_sobre_qualquer_npc = false
	var areas = get_overlapping_areas()
	
	for area in areas:
		if area in lista_npcs:
			esta_sobre_qualquer_npc = true
			break
	
	# Aqui é o único lugar do script que define o visible baseado na distância
	visible = not esta_sobre_qualquer_npc

func atualizar_alvo():
	if lista_npcs.size() > 0:
		alvo_atual = lista_npcs[0]
	else:
		alvo_atual = null
		visible = false

func proximo_objetivo():
	if lista_npcs.size() > 0:
		lista_npcs.remove_at(0) # Remove o que acabamos de completar
		atualizar_alvo()
		print("Seta atualizada! Novo alvo: ", alvo_atual.name if alvo_atual else "Nenhum")
