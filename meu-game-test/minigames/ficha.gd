extends TextureRect

@export var tipo_da_ficha: String = ""

var arrastando = false
var posicao_inicial: Vector2
@onready var area = $Area2D
var aceito_pelo_bau: bool = false

func _ready():
	posicao_inicial = global_position

func _process(_delta):
	if arrastando:
		global_position = get_global_mouse_position() - (size / 2)

func _gui_input(event):
	if aceito_pelo_bau: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				arrastando = true
				z_index = 10
				modulate.a = 0.5 # Efeito fantasma (50% de transparência)
			else:
				arrastando = false
				z_index = 1
				modulate.a = 1.0 # Volta ao normal (100% opaco)
				verificar_colisao()

func verificar_colisao():
	if aceito_pelo_bau or not area.monitoring:
		return

	# Movemos a área para onde o mouse soltou
	area.global_position = get_global_mouse_position()
	
	# Pequena espera para a física do Godot processar a sobreposição
	await get_tree().process_frame 

	var areas = area.get_overlapping_areas()
	var encostou_em_algum_bau = false
	
	for a in areas:
		var bau = a.get_parent()
		if bau.has_method("receber_ficha"):
			encostou_em_algum_bau = true
			
			# TESTE DE TIPO:
			# Se o tipo da ficha for igual ao que o baú espera
			if self.tipo_da_ficha == bau.tipo_esperado:
				bau.receber_ficha(self)
				return # Sai da função, tudo certo!
			else:
				# ERRO: Colocou no livro errado
				if owner.has_method("registrar_erro"):
					owner.registrar_erro()
				
				# Feedback visual de erro (opcional: o baú pode piscar vermelho)
				if bau.has_method("piscar"):
					bau.piscar(Color.RED)
				
				voltar_pro_lugar()
				return

	# Se chegou aqui e não encostou em NENHUM baú (soltou no void/mesa)
	if not encostou_em_algum_bau:
		voltar_pro_lugar()

func voltar_pro_lugar():
	modulate.a = 1.0 # Garante que volta a cor normal se errar
	global_position = posicao_inicial

func sumir():
	aceito_pelo_bau = true
	visible = false
	set_process(false)
	if has_node("Area2D"):
		$Area2D.monitorable = false
		$Area2D.monitoring = false
		
func preparar_nova_rodada():
	aceito_pelo_bau = false
	visible = true
	arrastando = false
	modulate.a = 1.0 # Reset da transparência
	set_process(true)
	
	if has_node("Area2D"):
		$Area2D.monitoring = true
		$Area2D.monitorable = true
		
	global_position = posicao_inicial
