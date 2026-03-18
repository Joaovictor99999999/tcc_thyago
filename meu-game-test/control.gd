extends Control

func _on_opcao_pressionada(opcao):
	print("Escolheu:", opcao)
	visible = false

func _ready():
	visible = false
	
func mostrar_dialogo(texto, opcoes):

	print("Mostrando dialogo")

	visible = true
	$Panel/Label.text = texto
