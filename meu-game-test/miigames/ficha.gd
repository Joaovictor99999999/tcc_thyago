extends TextureRect

@export var tipo_da_ficha: String = ""

# Guardamos a posição original em relação à mesa
var posicao_inicial: Vector2
var aceito_pelo_bau: bool = false 

func _ready() -> void:
	# Armazena a posição inicial para o "reset" caso o jogador erre
	posicao_inicial = global_position
	# Garante que a ficha fique acima do cenário (z_index)
	z_index = 1 
	# DICA: Aqui você pode carregar a sua nova arte se não quiser fazer pelo Inspector
	# texture = preload("res://sua_arte_da_folha.png")

func _get_drag_data(_at_position: Vector2) -> Variant:
	# Se já foi aceito, não deixa arrastar de novo
	if aceito_pelo_bau:
		return null

	# 1. Cria o fantasma para o arraste (Drag Preview)
	var fantasma = duplicate()
	fantasma.modulate.a = 0.5 
	
	var cabide = Control.new()
	cabide.add_child(fantasma)
	# Centraliza o fantasma no mouse
	fantasma.position = -size / 2
	
	set_drag_preview(cabide)
	
	# 2. Escondemos a ficha original para dar efeito de que ela "saiu" da mesa
	visible = false
	return self

func voltar_pro_lugar() -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	global_position = posicao_inicial
	
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		# Se o arraste terminou e nenhum baú chamou 'marcar_como_aceito'
		if not aceito_pelo_bau:
			voltar_pro_lugar()

func marcar_como_aceito():
	aceito_pelo_bau = true
	visible = false
	# Aqui você pode soltar um som de "acerto" ou uma partícula!
