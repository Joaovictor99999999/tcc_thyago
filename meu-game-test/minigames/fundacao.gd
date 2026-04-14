extends Control

# A receita de vitória padrão para as fases de 4 slots
const ORDEM_CORRETA = ["1", "2", "3", "4"]

func verificar_sequencia() -> bool:
	# Buscamos os 4 slots dentro do nó 'Slots'
	var p1 = $Slots/Slot1.peca_atual
	var p2 = $Slots/Slot2.peca_atual
	var p3 = $Slots/Slot3.peca_atual
	var p4 = $Slots/Slot4.peca_atual
	
	# Se algum slot estiver vazio, retorna falso (ainda não terminou)
	if not p1 or not p2 or not p3 or not p4:
		return false
	
	# Cria a lista com o que o jogador colocou
	var sequencia_jogador = [
		str(p1.id_parte), 
		str(p2.id_parte), 
		str(p3.id_parte), 
		str(p4.id_parte)
	]
	
	# Compara com a ordem correta ["1", "2", "3", "4"]
	return sequencia_jogador == ORDEM_CORRETA
