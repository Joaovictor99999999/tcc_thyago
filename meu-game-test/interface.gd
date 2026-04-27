extends Node2D

@onready var animador = $CanvasLayer/Sprite2D/AnimationPlayer
@onready var btn_comecar = $CanvasLayer/Começar
@onready var titulo = $CanvasLayer/Sprite2D/capa 

# Introdução
@onready var texto_1 = $CanvasLayer/Sprite2D/texto1
@onready var texto_2 = $CanvasLayer/Sprite2D/texto2
@onready var texto_3 = $CanvasLayer/Sprite2D/texto3
@onready var texto_4 = $CanvasLayer/Sprite2D/texto4 

# Final
@onready var vila_no_livro_2 = $CanvasLayer/Sprite2D/VilaNoLivro2
@onready var texto_5 = $CanvasLayer/Sprite2D/texto5
@onready var texto_6 = $CanvasLayer/Sprite2D/texto6

@onready var camera = $Camera2D 
@onready var vila_no_livro = $CanvasLayer/Sprite2D/VilaNoLivro 
@onready var moldura = $CanvasLayer/Sprite2D/VilaNoLivro/MolduraVila 

@onready var btn_proximo = $CanvasLayer/BtnProximo
@onready var btn_play_final = $CanvasLayer/BtnPlayFinal 

var tween_atual
var esta_encerrando = false

func criar_tween():
	if tween_atual:
		tween_atual.kill()
	tween_atual = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return tween_atual

func _ready():
	self.show()
	process_mode = Node.PROCESS_MODE_ALWAYS
	animador.process_mode = Node.PROCESS_MODE_ALWAYS
	$CanvasLayer.process_mode = Node.PROCESS_MODE_ALWAYS        # ← adiciona
	$CanvasLayer/Sprite2D.process_mode = Node.PROCESS_MODE_ALWAYS 
	resetar_labels()

	# Final escondido
	vila_no_livro_2.visible = false
	texto_5.visible = false
	texto_6.visible = false

	titulo.visible = true
	btn_comecar.visible = true

func resetar_labels():
	texto_1.visible_ratio = 0.0
	texto_2.visible_ratio = 0.0
	texto_3.visible_ratio = 0.0
	texto_4.visible_ratio = 0.0
	
	texto_1.visible = true
	texto_2.visible = true
	texto_3.visible = true
	texto_4.visible = false
	
	btn_proximo.visible = false
	btn_play_final.visible = false
	
	vila_no_livro.visible = false 
	moldura.visible = false

# --- ABRIR LIVRO ---
func _on_texture_button_pressed():
	titulo.visible = false 
	animador.play("abrir_livro")
	btn_comecar.visible = false

# modifica o _on_animation_player_animation_finished
func _on_animation_player_animation_finished(anim_name):
	print("🎬 Animação terminou: ", anim_name)  # ← adiciona isso
	if esta_encerrando:
		return
	match anim_name:
		"abrir_livro":
			escrever_historia_inicial()
		"passar_pagina":
			escrever_tutorial()

# --- HISTÓRIA ---
func escrever_historia_inicial():
	var tw = criar_tween()
	tw.tween_property(texto_1, "visible_ratio", 1.0, 8.0)
	tw.tween_property(texto_2, "visible_ratio", 1.0, 8.0)
	tw.finished.connect(func(): btn_proximo.visible = true)

# --- PASSAR PÁGINA ---
func _on_proximo_pressed():
	btn_proximo.visible = false
	texto_1.visible = false
	texto_2.visible = false
	
	if animador.has_animation("passar_pagina"):
		animador.play("passar_pagina")
		print("✅ Animação encontrada, tocando...")
	else:
		print("❌ Animação 'passar_pagina' não encontrada")

# --- TUTORIAL ---
func escrever_tutorial():
	vila_no_livro.modulate.a = 0.0
	moldura.modulate.a = 0.0
	
	vila_no_livro.visible = true
	moldura.visible = true
	
	var tw = criar_tween()
	tw.tween_property(texto_3, "visible_ratio", 1.0, 8.0)
	tw.parallel().tween_property(vila_no_livro, "modulate:a", 1.0, 4.0)
	tw.parallel().tween_property(moldura, "modulate:a", 1.0, 4.0)
	tw.finished.connect(func(): escrever_chamada_final())

func escrever_chamada_final():
	texto_4.visible = true
	texto_4.visible_ratio = 0.0
	
	var tw = criar_tween()
	tw.tween_property(texto_4, "visible_ratio", 1.0, 8.0)
	tw.finished.connect(func(): btn_play_final.visible = true)

# --- ZOOM ---
func _on_btn_play_final_pressed():
	btn_play_final.visible = false
	texto_3.visible = false
	texto_4.visible = false 
	
	camera.make_current() 
	
	var tw = criar_tween()
	tw.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	var alvo = vila_no_livro.global_position + Vector2(35, 20)
	tw.tween_property(camera, "zoom", Vector2(5.5, 5.0), 2.5)
	tw.parallel().tween_property(camera, "global_position", alvo, 2.5)

	tw.finished.connect(func():
		if owner and owner.has_method("liberar_mundo"):
			owner.liberar_mundo()
		camera.enabled = false 
		self.hide()
	)

# --- ENCERRAMENTO ---
func preparar_para_encerramento():
	self.show()
	self.modulate.a = 1.0

	# ESCONDE ELEMENTOS ANTIGOS
	vila_no_livro.visible = false
	moldura.visible = false

	# NOVA VILA
	vila_no_livro_2.visible = true
	vila_no_livro_2.modulate.a = 1.0

	# TEXTO 5 E 6 ANIMADOS
	texto_5.visible = true
	texto_5.visible_ratio = 0.0
	texto_5.text = "A historia de Murge ainda estao sendo escritas por voce.\n\nPor enquanto ficamos por aqui, mas logo voltaremos.\n\nObrigado por jogar!"

	texto_6.visible = false
	texto_6.visible_ratio = 0.0
	texto_6.text = "Continua..."

	var tw = criar_tween()
	tw.tween_property(texto_5, "visible_ratio", 1.0, 8.0)

	tw.tween_callback(func():
		texto_6.visible = true
	)

	tw.tween_property(texto_6, "visible_ratio", 1.0, 2.0)

func preparar_para_fechar():
	vila_no_livro.visible = false
	vila_no_livro_2.visible = false
	texto_5.visible = false
	texto_6.visible = false
	btn_proximo.visible = false
	btn_play_final.visible = false

func mostrar_capa():
	titulo.visible = true
	# ← adiciona essas linhas:
	btn_proximo.visible = false
	btn_play_final.visible = false
	texto_1.visible = false
	texto_2.visible = false
	texto_3.visible = false
	texto_4.visible = false
