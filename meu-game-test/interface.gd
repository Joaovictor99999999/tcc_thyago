extends Node2D

@onready var animador = $CanvasLayer/Sprite2D/AnimationPlayer
@onready var btn_comecar = $CanvasLayer/Começar
@onready var titulo = $CanvasLayer/Sprite2D/capa 

# Labels (filhas do Sprite2D)
@onready var texto_1 = $CanvasLayer/Sprite2D/texto1
@onready var texto_2 = $CanvasLayer/Sprite2D/texto2
@onready var texto_3 = $CanvasLayer/Sprite2D/texto3
@onready var texto_4 = $CanvasLayer/Sprite2D/texto4 # Novo texto de aventura

@onready var camera = $Camera2D 
@onready var vila_no_livro = $CanvasLayer/Sprite2D/VilaNoLivro 
@onready var moldura = $CanvasLayer/Sprite2D/MolduraVila # Certifique-se de que o nome está assim
@onready var btn_proximo = $CanvasLayer/BtnProximo
@onready var btn_play_final = $CanvasLayer/BtnPlayFinal 

func _ready():
	texto_1.visible_ratio = 0.0
	texto_2.visible_ratio = 0.0
	texto_3.visible_ratio = 0.0
	texto_4.visible_ratio = 0.0
	texto_4.visible = false
	btn_proximo.visible = false
	btn_play_final.visible = false
	vila_no_livro.visible = false 
	moldura.visible = false # Moldura começa escondida com a vila

# --- PASSO 1: CLIQUE NO BOTÃO DA CAPA ---
func _on_texture_button_pressed():
	titulo.visible = false 
	animador.play("abrir_livro")
	btn_comecar.queue_free()

# --- PASSO 2: CONTROLE DAS ANIMAÇÕES ---
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "abrir_livro":
		escrever_historia_inicial()
	elif anim_name == "passar_pagina":
		escrever_tutorial()

# --- PASSO 3: TEXTO 1 -> TEXTO 2 ---
func escrever_historia_inicial():
	var tween1 = get_tree().create_tween()
	tween1.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween1.tween_property(texto_1, "visible_ratio", 1.0, 3.0)
	
	tween1.finished.connect(func():
		var tween2 = get_tree().create_tween()
		tween2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween2.tween_property(texto_2, "visible_ratio", 1.0, 3.0)
		tween2.finished.connect(func(): btn_proximo.visible = true)
	)

# --- PASSO 4: PASSAR PÁGINA ---
func _on_proximo_pressed():
	btn_proximo.visible = false
	texto_1.visible = false
	texto_2.visible = false
	animador.play("passar_pagina")

# --- PASSO 5: TEXTO 3 -> TEXTO 4 -> PLAY ---
# --- PASSO 5: TEXTO 3 -> TEXTO 4 (Sem sumir o anterior) ---
func escrever_tutorial():
	# Preparamos a vila e a moldura
	vila_no_livro.modulate.a = 0.0
	moldura.modulate.a = 0.0
	vila_no_livro.visible = true
	moldura.visible = true
	
	var tween3 = get_tree().create_tween()
	tween3.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# Escreve o texto 3 e faz a foto/moldura aparecerem
	tween3.tween_property(texto_3, "visible_ratio", 1.0, 3.0) # Tempo ajustado para fluidez
	tween3.parallel().tween_property(vila_no_livro, "modulate:a", 1.0, 1.5)
	tween3.parallel().tween_property(moldura, "modulate:a", 1.0, 1.5)
	
	# Assim que o texto 3 terminar, já começa a escrever o 4 logo abaixo
	tween3.finished.connect(func():
		escrever_chamada_final()
	)

func escrever_chamada_final():
	# Ativamos o texto 4 sem mexer no texto 3
	texto_4.visible = true
	texto_4.visible_ratio = 0.0
	
	# Definimos o conteúdo do texto 4
	texto_4.text = "Agora que os segredos desta história foram revelados e você já domina os caminhos do conhecimento, chegou a hora. O livro se abre para o mundo... vamos desbravar esta aventura!"
	
	var tween4 = get_tree().create_tween()
	tween4.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# Escreve o texto 4 mantendo o 3 visível
	tween4.tween_property(texto_4, "visible_ratio", 1.0, 3.0)
	
	# Quando o 4 terminar, aí sim liberamos o botão de Play
	tween4.finished.connect(func():
		btn_play_final.visible = true
	)

# --- 🔥 PASSO 6: O ZOOM (Agora escondendo os dois textos antes de ir) ---
func _on_btn_play_final_pressed():
	btn_play_final.visible = false
	texto_3.visible = false
	texto_4.visible = false 
		
	camera.make_current() 
	var tween_camera = get_tree().create_tween()
	tween_camera.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	tween_camera.set_trans(Tween.TRANS_QUINT)
	tween_camera.set_ease(Tween.EASE_IN)
	
	var alvo = vila_no_livro.global_position + Vector2(35, 20) 
	
	tween_camera.tween_property(camera, "zoom", Vector2(5.5, 5.0), 2.5)
	tween_camera.parallel().tween_property(camera, "global_position", alvo, 2.5)

	tween_camera.finished.connect(func():
		if owner and owner.has_method("liberar_mundo"):
			owner.liberar_mundo()
		queue_free()
	)
	
