extends Control 

@export var tipo_esperado: String = ""
@onready var visual_poligono = $Brilho_Neon 

func _can_drop_data(_pos, data):
	# Verifica se o dado arrastado tem a variável que precisamos
	return data is Control and "tipo_da_ficha" in data

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# Busca o script principal (CanvasLayer) para registrar pontos
	var cerebro = get_tree().current_scene 
	# Se o minigame for uma cena instanciada, 'owner' costuma funcionar melhor:
	if owner and owner.has_method("registrar_acerto"):
		cerebro = owner

	if data.tipo_da_ficha == tipo_esperado:
		piscar_brilho(Color.GREEN)
		if data.has_method("marcar_como_aceito"):
			data.marcar_como_aceito()
		cerebro.registrar_acerto() 
	else:
		piscar_brilho(Color.RED)
		cerebro.registrar_erro()
		# O papel volta para a mesa se errar
		data.voltar_pro_lugar()

func piscar_brilho(cor: Color) -> void:
	if visual_poligono:
		visual_poligono.modulate = cor # Forma simples de mudar a cor se for um sprite ou polygon
		visual_poligono.show()
		
		await get_tree().create_timer(0.6).timeout
		
		visual_poligono.hide()
