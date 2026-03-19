extends Node2D

var minigame_aberto = false

func _ready():
	# IMPORTANTE: O Level Manager precisa ignorar o pause para gerenciar as telas
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Conecta os NPCs existentes
	conectar_npcs()

func conectar_npcs():
	# Busca todos os NPCs no grupo e conecta se ainda não estiverem conectados
	for npc in get_tree().get_nodes_in_group("npc"):
		if not npc.iniciar_minigame.is_connected(_on_iniciar_minigame):
			npc.iniciar_minigame.connect(_on_iniciar_minigame)

func _on_iniciar_minigame(scene):
	if minigame_aberto:
		return

	minigame_aberto = true
	var instancia = scene.instantiate()
	instancia.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child.call_deferred(instancia)

	await get_tree().process_frame
	get_tree().paused = true
	
	# MUDANÇA AQUI: Usamos tree_exiting (no gerúndio) para agir antes do nó sumir de vez
	instancia.tree_exiting.connect(_on_minigame_fechado)

func _on_minigame_fechado():
	# Proteção: Se a árvore de cenas sumiu (jogo fechando), não fazemos nada
	var tree = get_tree()
	if not tree:
		return

	minigame_aberto = false
	
	# Despausa o jogo
	tree.paused = false
	
	# Notifica NPCs com segurança
	for npc in tree.get_nodes_in_group("npc"):
		if is_instance_valid(npc) and npc.has_method("bloquear_interacao_temporariamente"):
			npc.bloquear_interacao_temporariamente()
