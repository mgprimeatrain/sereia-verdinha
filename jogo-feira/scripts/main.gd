extends Node
## Controla o jogo: tela de título, mapa, inspeção e coleção.
## Teclas extras: F11 = tela cheia, F2 = recomeçar (para o próximo visitante da feira).
## Shift = correr, Espaço = pular.

const CONTROLES := {
	"cima": [KEY_W, KEY_UP],
	"baixo": [KEY_S, KEY_DOWN],
	"esquerda": [KEY_A, KEY_LEFT],
	"direita": [KEY_D, KEY_RIGHT],
	"interagir": [KEY_E, KEY_ENTER, KEY_KP_ENTER],
	"pular": [KEY_SPACE],
	"correr": [KEY_SHIFT],
	"cancelar": [KEY_ESCAPE],
	"tela_cheia": [KEY_F11],
	"recomecar": [KEY_F2],
}

var mundo: Node2D
var tela: SubViewportContainer
var mapa: Mapa
var jogador: Jogador
var sala_atual := ""
var ui: Interface
var estado := "titulo"  # titulo, jogando, inspecionando, trocando_sala, falando, quiz
var falas_ditas := {}
var vistos := {}
var total := 0
var proximo: Inspecionavel
var parabens_mostrado := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configurar_controles()
	total = Dados.total_componentes()

	# O mundo é desenhado em baixa resolução (240x135) e ampliado 8x em Full HD,
	# por isso fica com pixels grandes, iguais aos do coelho.
	# A imagem tem 1 pixel a mais de cada lado: a tela inteira desliza um
	# pedacinho de pixel para a câmera andar lisinha, sem tremer.
	# A interface fica nítida por cima.
	RenderingServer.set_default_clear_color(Color("14121a"))
	tela = SubViewportContainer.new()
	tela.process_mode = Node.PROCESS_MODE_PAUSABLE
	tela.scale = Vector2(2, 2)
	add_child(tela)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(242, 137)
	tela.size = Vector2(242, 137)
	viewport.snap_2d_transforms_to_pixel = true
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	tela.add_child(viewport)

	mapa = Mapa.new()
	viewport.add_child(mapa)
	mapa.montar()
	jogador = Jogador.new()
	jogador.mapa = mapa
	mapa.add_child(jogador)
	jogador.posicionar(Mapa.centro(Dados.INICIO))
	mapa.escuridao.alvo = jogador
	Parede.alvo = jogador

	ui = Interface.new()
	add_child(ui)
	ui.atualizar_contador(0, total)
	get_tree().paused = true


func _configurar_controles() -> void:
	for acao in CONTROLES:
		if InputMap.has_action(acao):
			InputMap.action_erase_events(acao)
		else:
			InputMap.add_action(acao)
		for tecla in CONTROLES[acao]:
			var evento := InputEventKey.new()
			evento.physical_keycode = tecla
			InputMap.action_add_event(acao, evento)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tela_cheia"):
		var cheia := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if cheia else DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	if event.is_action_pressed("recomecar"):
		get_tree().paused = false
		get_tree().reload_current_scene()
		return

	match estado:
		"titulo":
			if event.is_action_pressed("interagir"):
				estado = "jogando"
				get_tree().paused = false
				ui.esconder_titulo()
				_atualizar_sala()
		"jogando":
			if event.is_action_pressed("interagir") and proximo:
				_abrir(proximo)
		"inspecionando":
			if event.is_action_pressed("interagir") or event.is_action_pressed("cancelar"):
				_fechar()
		"falando":
			if event.is_action_pressed("interagir") or event.is_action_pressed("cancelar"):
				if ui.fala.avancar():
					get_tree().paused = false
					estado = "jogando"
		"quiz":
			if ui.quiz.tratar(event):
				get_tree().paused = false
				estado = "jogando"
				if ui.quiz.terminou:
					ui.mostrar_aviso("Você acertou %d de %d no quiz!" % [ui.quiz.acertos, Dados.QUIZ.size()], 4.0)


func _process(delta: float) -> void:
	jogador.atualizar_camera(delta)
	tela.position = -(Vector2.ONE + jogador.fracao) * tela.scale
	if estado != "jogando":
		return
	_atualizar_sala()
	# acha o objeto mais perto do coelho (se tiver algum ao alcance)
	var melhor: Inspecionavel = null
	var menor := 26.0
	for objeto in mapa.objetos:
		var d := objeto.logico.distance_to(jogador.logico)
		if d < menor:
			menor = d
			melhor = objeto
	for objeto in mapa.objetos:
		objeto.destacado = objeto == melhor
	proximo = melhor
	if melhor == null:
		ui.mostrar_dica("")
	elif melhor.info.get("tipo", "") == "quiz":
		ui.mostrar_dica("[E] Jogar o quiz!")
	else:
		ui.mostrar_dica("[E] Inspecionar: " + melhor.info["nome"])


## Quando o coelho entra em outra sala: a tela escurece, volta e mostra o nome dela.
func _atualizar_sala() -> void:
	var id := mapa.sala_em(jogador.logico)
	if id == "" or id == sala_atual:
		return
	var primeira_vez := sala_atual == ""
	sala_atual = id
	if primeira_vez:
		_mostrar_sala(id)
		_falar_da_sala(id)
		return
	estado = "trocando_sala"
	ui.mostrar_dica("")
	jogador.set_process(false)
	await ui.fade(true)
	_mostrar_sala(id)
	jogador.set_process(true)
	await ui.fade(false)
	estado = "jogando"
	_falar_da_sala(id)


## Na primeira vez em cada sala, o coelho explica o tema dela.
func _falar_da_sala(id: String) -> void:
	if falas_ditas.has(id) or not Dados.SALAS[id].has("fala"):
		return
	falas_ditas[id] = true
	estado = "falando"
	get_tree().paused = true
	ui.mostrar_dica("")
	ui.fala.mostrar(Dados.SALAS[id]["fala"])


func _mostrar_sala(id: String) -> void:
	ui.mostrar_sala(Dados.SALAS[id]["nome"])
	# a sala atual (com as paredes do fundo) fica visível; o resto some no escuro
	var area: Rect2i = Dados.SALAS[id]["area"]
	var r := Rect2(Vector2(area.position - Vector2i(3, 3)), Vector2(area.size + Vector2i(4, 4)))
	mapa.escuridao.definir_sala(Rect2(r.position * Mapa.CELULA, r.size * Mapa.CELULA))
	mapa.mostrar_sala(id)


func _contar_achados() -> int:
	var achados := 0
	for id in vistos:
		if Dados.conta(id):
			achados += 1
	return achados


func _abrir(objeto: Inspecionavel) -> void:
	get_tree().paused = true
	ui.mostrar_dica("")
	if objeto.info.get("tipo", "") == "quiz":
		estado = "quiz"
		objeto.visto = true
		ui.quiz.comecar()
		return
	estado = "inspecionando"
	var novo := Dados.conta(objeto.id) and not vistos.has(objeto.id)
	vistos[objeto.id] = true
	objeto.visto = true
	ui.atualizar_contador(_contar_achados(), total)
	ui.abrir_inspecao(objeto.info, objeto.textura, novo, total)


func _fechar() -> void:
	ui.fechar_inspecao()
	get_tree().paused = false
	estado = "jogando"
	if _contar_achados() == total and not parabens_mostrado:
		parabens_mostrado = true
		ui.mostrar_aviso("PARABÉNS! Você descobriu todos os %d componentes! Você é um verdadeiro cientista!" % total, 6.0)
