extends Node2D

func _ready():
	$AnimationPlayer.play("idle")
	
var player_perto = false

func _on_area_2d_body_entered(body):
	if body.name == "Character":
		player_perto = true

func _on_area_2d_body_exited(body):
	if body.name == "Character":
		player_perto = false

func _process(delta):
	if player_perto and Input.is_action_just_pressed("interact"):
		iniciar_dialogo()

func iniciar_dialogo():
	print("Dialogo chamado")

	var dialogo = get_tree().current_scene.get_node("Dialogo")
	dialogo.mostrar_dialogo(
		"Olá aventureiro, quer jogar?",
		["Sim","Não"]
	)
