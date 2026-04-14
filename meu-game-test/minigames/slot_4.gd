extends TextureRect

var peca_atual: TextureRect = null

func _can_drop_data(_pos, data):
	# Aceita qualquer peça que tenha o ID de parte
	return data is TextureRect and "id_parte" in data

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# Se já existe uma peça neste slot, mandamos ela de volta para a origem dela
	if peca_atual:
		peca_atual.voltar_para_origem()
	
	# Recebemos a nova peça
	peca_atual = data
	peca_atual.no_slot = true
	
	# Fazemos a peça (invisível) ficar na mesma posição visual deste slot
	peca_atual.global_position = global_position
	
	# Atualizamos a textura deste slot para parecer que a peça "encaixou"
	texture = peca_atual.texture
	
	# Opcional: Se quiser que a peça original suma da mão do jogador
	peca_atual.visible = false
