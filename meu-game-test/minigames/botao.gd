extends TextureRect

@export var id_parte: String = "" # ID que deve bater com o gabarito do Gerenciador

var pos_repouso: Vector2
var no_slot: bool = false
var ultimo_slot = null

func _ready():
	# Adicione a peça ao grupo "botoes" para o Gerenciador e o Slot a encontrarem
	add_to_group("botoes")
	pos_repouso = global_position
	mouse_filter = Control.MOUSE_FILTER_STOP

# 🎯 FUNÇÃO DE ENCAIXE (Centraliza a peça no slot)
func mover_para_posicao(destino_slot: Vector2, tamanho_slot: Vector2 = Vector2.ZERO):
	if tamanho_slot != Vector2.ZERO:
		var centro = destino_slot + (tamanho_slot / 2)
		global_position = centro - (size / 2)
	else:
		global_position = destino_slot
	
	modulate.a = 1.0 # Restaura a cor total ao encaixar

# 🔄 VOLTAR PARA O ALMOXARIFADO (A Coluna Lateral)
func voltar_pro_lugar():
	ultimo_slot = null
	no_slot = false
	global_position = pos_repouso
	modulate.a = 1.0

# 🖱️ INÍCIO DO ARRASTO (O Godot chama isso sozinho ao clicar e arrastar)
func _get_drag_data(_at_position: Vector2) -> Variant:
	if ultimo_slot != null:
		ultimo_slot.limpar_slot() 
	# Criamos o "Fantasma" que segue o mouse
	var fantasma = TextureRect.new()
	fantasma.texture = texture
	fantasma.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	fantasma.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fantasma.custom_minimum_size = size
	fantasma.modulate.a = 0.5
	set_drag_preview(fantasma)

	# A peça real fica transparente enquanto arrastamos
	modulate.a = 0.3
	
	# Importante: Quando começamos a arrastar, ela tecnicamente sai do slot
	no_slot = false

	# Pacote de dados que o Slot vai receber no '_drop_data'
	return {
		"objeto": self,
		"slot_origem": ultimo_slot,
		"id": id_parte
	}

# 🔚 FINAL DO ARRASTO (O "Juiz" do Godot avisa quando soltamos o mouse)
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		# Se a peça não foi aceita por nenhum slot (no_slot continua false)
		if not no_slot:
			voltar_pro_lugar()
		else:
			# Se foi aceita, apenas garante que ela brilha de novo
			modulate.a = 1.0
