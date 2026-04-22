extends Node2D

@onready var animador = $CanvasLayer/Sprite2D/AnimationPlayer
@onready var botao_textura = $CanvasLayer/Começar
@onready var label_historia = $CanvasLayer/Sprite2D/RichTextLabel # Ajuste o caminho para o seu Label

func _ready():
	# Garante que o texto comece invisível
	label_historia.visible_ratio = 0.0

func _on_texture_button_pressed():
	# 1. Toca a animação de abrir
	animador.play("abrir_livro")
	
	# 2. Remove o botão
	botao_textura.queue_free()

# Conecte o sinal 'animation_finished' do seu AnimationPlayer a esta função
func _on_animation_player_animation_finished(anim_name):
	print("Animação terminou: ", anim_name)
	if anim_name == "abrir_livro":
		# Chama a função que escreve o texto
		escrever_texto()

func escrever_texto():
	# Criamos um Tween para animar a propriedade 'visible_ratio' de 0 a 1
	# O número 2.0 é a duração em segundos (aumente para ser mais lento)
	var tween = get_tree().create_tween()
	tween.tween_property(label_historia, "visible_ratio", 1.0, 6.0)
