extends Node2D

func _ready():
	# Forçamos o pause
	get_tree().paused = true
	
	# Verificação no console
	print("Estado do pause no servidor: ", get_tree().paused)
	
	# Se você renomeou o nó para 'interface'
	if has_node("interface"):
		$interface.show()
		print("Interface mostrada.")
	else:
		# Se ainda estiver como Node2D
		$Node2D.show()
		print("Node2D mostrado.")

# Função que a Interface vai chamar no final do Zoom
func liberar_mundo():
	get_tree().paused = false
	print("Mundo despausado!")
