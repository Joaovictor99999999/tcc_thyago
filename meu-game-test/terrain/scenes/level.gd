extends Node2D

var progresso_atual = 0

func _ready():
	# Forçamos o pause
	get_tree().paused = true
	
	# Verificação no console
	print("Estado do pause no servidor: ", get_tree().paused)
	
	# Se você renomeou o nó para 'interface'
	if has_node("interface"):
		$ysort/Character/Camera2D/interface.show()
		print("Interface mostrada.")

func _input(event):
	# Se apertar a tecla "K" (de King/Fim), chama o encerramento
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		print("Debug: Testando encerramento...")
		iniciar_encerramento()
		
var posicao_camera_inicio: Vector2
var zoom_camera_inicio: Vector2

# Esta é a função que você já tem, vamos apenas adicionar o "print" da memória
func liberar_mundo():
	get_tree().paused = false
	
	# No momento que o jogo começa, salvamos onde a câmera parou
	var cam = get_viewport().get_camera_2d()
	if cam:
		posicao_camera_inicio = cam.global_position
		zoom_camera_inicio = cam.zoom
		print("📸 Memória da câmera salva: Pos ", posicao_camera_inicio, " Zoom ", zoom_camera_inicio)
	iniciar_ponte_inicial()
	
func pode_jogar(id_minigame: int) -> bool:
	return id_minigame == progresso_atual
	
# Adicione isso ao seu level.gd existente
func iniciar_encerramento():
	get_tree().paused = true 
	print("--- INICIANDO ENCERRAMENTO ---")
	
	# 1. Busca a interface no caminho da sua árvore de cenas
	var interface_node = get_node_or_null("ysort/Character/Camera2D/interface")
	if interface_node:
		interface_node.show()
		interface_node.btn_proximo.visible = false
		interface_node.btn_play_final.visible = false
		if interface_node.has_method("preparar_para_encerramento"):
			interface_node.preparar_para_encerramento()
		
		# 2. Configura a câmera da interface para o retorno
		var cam_interface = interface_node.get_node_or_null("Camera2D")
		
		if cam_interface:
			print("📸 Câmera detectada. Iniciando encaixe final...")
			cam_interface.enabled = true
			cam_interface.make_current()
			
			var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tw.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			
			# Coordenadas de encaixe perfeito que você testou
			var offset_ajuste = Vector2(180, 90) 
			
			# Executa o zoom out e o reposicionamento ao mesmo tempo
			tw.tween_property(cam_interface, "zoom", Vector2(1, 1), 2.5)
			tw.parallel().tween_property(cam_interface, "position", offset_ajuste, 2.5)
			
			tw.finished.connect(func():
				print("🏁 Zoom concluído. Mostrando despedida e 'Continua'...")
				
				# Espera 6 segundos (tempo para o jogador ler com calma)
				await get_tree().create_timer(11.0).timeout
				if interface_node.has_method("preparar_para_fechar"):
					interface_node.preparar_para_fechar()
				# 3. Finaliza fechando o livro com a animação invertida
				if interface_node.animador:
					interface_node.esta_encerrando = true
					interface_node.animador.play("abrir_livro", -1, -1.0, true)
					print("📖 O livro fechou-se. Fim da demo com sucesso!")
					await interface_node.animador.animation_finished
					interface_node.mostrar_capa()
			)
		else:
			print("❌ Erro: Camera2D não encontrada dentro da interface.")
	else:
		print("❌ Erro: Caminho 'ysort/Character/Camera2D/interface' não encontrado!")
		
func _sequencia_fechamento_livro(interface_node):
	# Usamos o caminho CURTO, direto de dentro da cena que acabamos de carregar
	# Remova o "ysort/Character/Camera2D/interface" pois o interface_node já é isso!
	var animador = interface_node.get_node("CanvasLayer/Sprite2D/AnimationPlayer")
	
	if animador:
		# Toca a animação de fechar o livro
		if animador.has_animation("abrir_livro"):
			# Play(nome, custom_blend, custom_speed, from_end)
			# -1.0 na velocidade e True no from_end faz ela tocar de trás pra frente
			animador.play("abrir_livro", -1, -1.0, true) 
	
	
	# Criar o texto final (opcional, mas fica bonito)
	var label_fim = Label.new()
	label_fim.text = "\n\n\n\nContinua..."
	label_fim.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_fim.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# Adicionamos na CanvasLayer dessa interface
	interface_node.get_node("CanvasLayer").add_child(label_fim)
	
	print("📖 FIM DA AVENTURA: CONTINUA...")
	
func iniciar_ponte_final():
	# 1. Garante que o jogo não está pausado para o diálogo processar
	get_tree().paused = false
	
	# 2. Pequeno delay para o jogador ver o Murge no mapa após o minigame fechar
	await get_tree().create_timer(0.5).timeout
	
	print("💬 Iniciando diálogo de epílogo no mapa...")
	exibir_dialogo_fim_de_jogo() 
	
func iniciar_ponte_inicial():
	# 1. Garante que o jogo não está pausado para o diálogo processar
	get_tree().paused = false
	
	# 2. Pequeno delay para o jogador ver o Murge no mapa após o minigame fechar
	await get_tree().create_timer(0.5).timeout
	
	print("💬 Iniciando diálogo de epílogo no mapa...")
	exibir_dialogo_inicio_de_jogo() 

func exibir_dialogo_fim_de_jogo():
	# 3. Carrega e instancia a sua cena de diálogo
	var dialogo_scene = load("res://minigames/dialogue_box.tscn")
	var dialogo = dialogo_scene.instantiate()
	add_child(dialogo)
	
	# 4. Conecta o sinal de finalização para chamar o livro
	dialogo.connect("dialogo_finalizado", func():
		print("📖 Diálogo encerrado. Iniciando cutscene do livro...")
		iniciar_encerramento()
	)
	
	# 5. Configura o texto de despedida (ajuste o caminho da imagem se necessário)
	dialogo.iniciar_dialogo(
		[
		"Obrigado pela ajuda Merge, por hoje é só, descanse.",
		"Em outro momento continuaremos essa historia.",
		"O livro desta aventura está prestes a se fechar... por enquanto."],
		preload("res://character/assets/fazendeiro.png") # Certifique-se que o caminho existe
	)
	
func exibir_dialogo_inicio_de_jogo():
	# 3. Carrega e instancia a sua cena de diálogo
	var dialogo_scene = load("res://minigames/dialogue_box.tscn")
	var dialogo = dialogo_scene.instantiate()
	add_child(dialogo)
	
	# 4. Conecta o sinal de finalização para chamar o livro
	dialogo.connect("dialogo_finalizado", func():
		print("📖 Diálogo encerrado. Iniciando cutscene do livro...")
	)
	
	# 5. Configura o texto de despedida (ajuste o caminho da imagem se necessário)
	dialogo.iniciar_dialogo(
		[
		"Para voce que chegou agora.",
		"Siga a seta para concluir os desafios, o resto voce descobre."],
		preload("res://character/assets/vovo.png") # Certifique-se que o caminho existe
	)
	
