extends Control # Ou NinePatchRect, dependendo do seu nó

# A receita de vitória desta fase específica
const ORDEM_CORRETA = ["fundacao", "estrutura", "piso"]

func verificar_sequencia() -> bool:
	# Pegamos as peças que estão guardadas nos slots
	var p1 = $Slots/Slot4.peca_atual
	var p2 = $Slots/Slot2.peca_atual
	var p3 = $Slots/Slot3.peca_atual
	
	# Se algum slot estiver vazio, já retorna erro
	if not p1 or not p2 or not p3:
		return false
	
	# Cria a lista do que o jogador montou
	var sequencia_jogador = [p1.id_parte, p2.id_parte, p3.id_parte]
	
	# Compara com a ordem correta
	return sequencia_jogador == ORDEM_CORRETA
