class_name Quiz
extends PanelContainer
## O quiz do final (as perguntas ficam em Dados.QUIZ).
## W/S ou setas escolhem, E confirma, 1/2/3 respondem direto, Esc sai.

var titulo: Label
var pergunta: Label
var opcoes: Array[Label] = []
var caixas: Array[PanelContainer] = []
var resposta: Label
var dica: Label

var indice := 0
var escolha := 0
var respondida := false
var terminou := false
var acertos := 0


func _ready() -> void:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.08, 0.12, 0.97)
	estilo.border_color = Color("f0c040")
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(4)
	estilo.set_content_margin_all(12)
	estilo.shadow_color = Color(0, 0, 0, 0.5)
	estilo.shadow_size = 6
	add_theme_stylebox_override("panel", estilo)
	custom_minimum_size = Vector2(400, 0)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 6)
	add_child(coluna)
	titulo = _label("", 9, Color("f0c040"))
	coluna.add_child(titulo)
	pergunta = _label("", 11, Color.WHITE)
	pergunta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coluna.add_child(pergunta)
	for i in 3:
		var caixa := PanelContainer.new()
		var estilo_opcao := StyleBoxFlat.new()
		estilo_opcao.set_border_width_all(1)
		estilo_opcao.set_corner_radius_all(3)
		estilo_opcao.set_content_margin_all(4)
		estilo_opcao.content_margin_left = 8
		caixa.add_theme_stylebox_override("panel", estilo_opcao)
		var l := _label("", 9, Color.WHITE)
		caixa.add_child(l)
		coluna.add_child(caixa)
		caixas.append(caixa)
		opcoes.append(l)
	resposta = _label("", 8, Color.WHITE)
	resposta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coluna.add_child(resposta)
	dica = _label("", 6, Color("9a9aa8"))
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	coluna.add_child(dica)
	visible = false


func _label(conteudo: String, tamanho: int, cor: Color) -> Label:
	var l := Label.new()
	l.text = conteudo
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	return l


func comecar() -> void:
	indice = 0
	acertos = 0
	terminou = false
	visible = true
	_mostrar_pergunta()


func _mostrar_pergunta() -> void:
	var q: Array = Dados.QUIZ[indice]
	titulo.text = "QUIZ  -  Pergunta %d de %d" % [indice + 1, Dados.QUIZ.size()]
	pergunta.text = q[0]
	for i in 3:
		opcoes[i].text = "%d)  %s" % [i + 1, q[1][i]]
		caixas[i].visible = true
	escolha = 0
	respondida = false
	resposta.text = ""
	dica.text = "W/S ou setas: escolher     E: responder     Esc: sair"
	_pintar()


func _pintar() -> void:
	var certa: int = Dados.QUIZ[indice][2] if not terminou else -1
	for i in 3:
		var estilo: StyleBoxFlat = caixas[i].get_theme_stylebox("panel")
		var fundo := Color(1, 1, 1, 0.06)
		var borda := Color(1, 1, 1, 0.15)
		if respondida and i == certa:
			fundo = Color("2f7a3a")
			borda = Color("7dff8a")
		elif respondida and i == escolha:
			fundo = Color("7a2f2f")
			borda = Color("ff7d7d")
		elif not respondida and i == escolha:
			fundo = Color(0.5, 0.88, 1.0, 0.25)
			borda = Color("7fe0ff")
		estilo.bg_color = fundo
		estilo.border_color = borda


## Recebe as teclas enquanto o quiz está aberto. Devolve true quando ele fecha.
func tratar(event: InputEvent) -> bool:
	if event.is_action_pressed("cancelar"):
		visible = false
		return true
	if terminou:
		if event.is_action_pressed("interagir"):
			visible = false
			return true
		return false
	if not respondida:
		if event.is_action_pressed("cima"):
			escolha = (escolha + 2) % 3
			_pintar()
		elif event.is_action_pressed("baixo"):
			escolha = (escolha + 1) % 3
			_pintar()
		elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode in [KEY_1, KEY_2, KEY_3, KEY_KP_1, KEY_KP_2, KEY_KP_3]:
			escolha = [KEY_1, KEY_2, KEY_3, KEY_KP_1, KEY_KP_2, KEY_KP_3].find(event.physical_keycode) % 3
			_responder()
		elif event.is_action_pressed("interagir"):
			_responder()
	elif event.is_action_pressed("interagir"):
		indice += 1
		if indice < Dados.QUIZ.size():
			_mostrar_pergunta()
		else:
			_final()
	return false


func _responder() -> void:
	respondida = true
	var q: Array = Dados.QUIZ[indice]
	if escolha == q[2]:
		acertos += 1
		resposta.text = "Isso! " + q[3]
		resposta.add_theme_color_override("font_color", Color("7dff8a"))
	else:
		resposta.text = "Quase! A certa é: %s. %s" % [q[1][q[2]], q[3]]
		resposta.add_theme_color_override("font_color", Color("ffb07d"))
	dica.text = "E: próxima pergunta" if indice < Dados.QUIZ.size() - 1 else "E: ver o resultado"
	_pintar()


func _final() -> void:
	terminou = true
	var total := Dados.QUIZ.size()
	titulo.text = "QUIZ  -  Resultado"
	var elogio := "Você é um verdadeiro cientista!" if acertos == total else ("Mandou muito bem!" if acertos >= total - 2 else "Explore as salas e tente de novo!")
	pergunta.text = "Você acertou %d de %d perguntas! %s" % [acertos, total, elogio]
	for caixa in caixas:
		caixa.visible = false
	resposta.text = "Obrigado pela atenção! Ficou com alguma dúvida, é só perguntar!"
	resposta.add_theme_color_override("font_color", Color("f0c040"))
	dica.text = "E: fechar"
