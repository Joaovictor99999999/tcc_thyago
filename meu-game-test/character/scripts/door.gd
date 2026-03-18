class_name DoorComponent
extends Area2D

@export var _teleport_position: Vector2
@export var _teleport_duration: float = 0.0

@onready var animation_player = $AnimationPlayer

static var _esta_teleportando: bool = false

var player_atual: Character


func _ready():
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)


func _on_body_entered(_body) -> void:
	if _body is Character and not _esta_teleportando:
		_esta_teleportando = true
		player_atual = _body
		
		# 🚪 abre a porta
		animation_player.play("abrir")


func _on_animation_finished(anim_name):

	if anim_name == "abrir":
		iniciar_teleporte(player_atual)

	elif anim_name == "fechar":
		finalizar_teleporte()


func iniciar_teleporte(player: Character):

	var tween = get_tree().create_tween()

	tween.tween_property(player, "global_position", _teleport_position, _teleport_duration)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# depois do teleporte → fechar porta
	tween.tween_callback(func():
		animation_player.play("fechar")
	)


func finalizar_teleporte():
	await get_tree().create_timer(0.2).timeout
	_esta_teleportando = false
