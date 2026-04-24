extends Sprite2D

@export var tipo_esperado: String = "" # No Inspector: "string", "float" ou "int"
@onready var brilho = $Brilho_Neon

func receber_ficha(ficha):
	if ficha.tipo_da_ficha == tipo_esperado:
		ficha.sumir() 
		piscar(Color.GREEN)
		
		if owner.has_method("registrar_acerto"):
			# Buscamos o nó Label que é filho da ficha para pegar o texto
			var texto_valor = ficha.get_node("Label").text 
			
			# Agora passamos os dados para o script principal
			owner.registrar_acerto(ficha.tipo_da_ficha, texto_valor)
	else:
		piscar(Color.RED)
		ficha.voltar_pro_lugar()

func piscar(cor):
	brilho.modulate = cor
	brilho.show()
	await get_tree().create_timer(0.5).timeout
	brilho.hide()
