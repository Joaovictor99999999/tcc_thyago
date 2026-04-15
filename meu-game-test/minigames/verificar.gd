extends TextureButton


func _pressed():
	print("🟢 BOTÃO FOI CLICADO")
	var gerenciador = get_tree().get_first_node_in_group("gerenciador_fase")
	print("Gerenciador:", gerenciador)
	
	if gerenciador:
		gerenciador.verificar_resposta()
