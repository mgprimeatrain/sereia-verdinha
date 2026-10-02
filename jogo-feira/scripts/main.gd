extends Node
## Controla o jogo: tela de título, troca de salas, inspeção e coleção.
## Teclas extras: F11 = tela cheia, F2 = recomeçar (para o próximo visitante da feira).

const CONTROLES := {
	"cima": [KEY_W, KEY_UP],
	"baixo": [KEY_S, KEY_DOWN],
	"esquerda": [KEY_A, KEY_LEFT],
	"direita": [KEY_D, KEY_RIGHT],
	"interagir": [KEY_E, KEY_ENTER, KEY_KP_ENTER, KEY_SPACE],
	"cancelar": [KEY_ESCAPE],
	"tela_cheia": [KEY_F11],
	"recomecar": [KEY_F2],
}

var mundo: Node2D
var jogador: Jogador
var sala: Sala
var ui: Interface
var estado := "titulo"  # titulo, jogando, inspecionando, trocando_sala
var vistos := {}
var total := 0
var proximo: Inspecionavel
var parabens_mostrado := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configurar_controles()
	total = Dados.total_componentes()

	# O mundo é desenhado em baixa resolução (320x180) e ampliado,
	# por isso fica com cara de pixel art e a câmera fica bem perto do coelho.
	# A interface fica nítida por cima.
	RenderingServer.set_default_clear_color(Color.BLACK)
	var tela := SubViewportContainer.new()
	tela.process_mode = Node.PROCESS_MODE_PAUSABLE
	tela.scale = Vector2(1.5, 1.5)
	add_child(tela)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(320, 180)
	tela.size = Vector2(320, 180)
	viewport.snap_2d_transforms_to_pixel = true
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	tela.add_child(viewport)

	mundo = Node2D.new()
	viewport.add_child(mundo)
	jogador = Jogador.new()

	ui = Interface.new()
	add_child(ui)
	ui.atualizar_contador(0, total)

	_carregar_sala(Dados.SALA_INICIAL, "")
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
				ui.mostrar_sala(sala.dados["nome"])
		"jogando":
			if event.is_action_pressed("interagir") and proximo:
				_abrir(proximo)
		"inspecionando":
			if event.is_action_pressed("interagir") or event.is_action_pressed("cancelar"):
				_fechar()


func _process(_delta: float) -> void:
	if estado != "jogando":
		return
	# acha o objeto mais perto do coelho (se tiver algum ao alcance)
	var melhor: Inspecionavel = null
	var menor := INF
	for objeto in sala.objetos:
		if objeto.perto:
			var d := objeto.position.distance_to(jogador.position)
			if d < menor:
				menor = d
				melhor = objeto
	for objeto in sala.objetos:
		objeto.destacado = objeto == melhor
	proximo = melhor
	ui.mostrar_dica("[E] Inspecionar: " + melhor.info["nome"] if melhor else "")


func _carregar_sala(id: String, origem: String) -> void:
	if sala:
		sala.remove_child(jogador)
		sala.queue_free()
	sala = Sala.new()
	sala.configurar(id)
	mundo.add_child(sala)
	sala.porta_tocada.connect(_trocar_sala)
	for objeto in sala.objetos:
		objeto.visto = vistos.has(objeto.id)

	sala.add_child(jogador)
	jogador.position = sala.ponto_chegada(origem)
	jogador.direcao = sala.direcao_chegada(origem)
	jogador.ajustar_camera(sala.tamanho)
	sala.escuridao.alvo = jogador
	proximo = null


func _trocar_sala(destino: String) -> void:
	if estado != "jogando":
		return
	estado = "trocando_sala"
	ui.mostrar_dica("")
	jogador.set_physics_process(false)
	await ui.fade(true)
	_carregar_sala(destino, sala.id)
	ui.mostrar_sala(sala.dados["nome"])
	await get_tree().process_frame
	jogador.set_physics_process(true)
	await ui.fade(false)
	estado = "jogando"


func _contar_achados() -> int:
	var achados := 0
	for id in vistos:
		if Dados.conta(id):
			achados += 1
	return achados


func _abrir(objeto: Inspecionavel) -> void:
	estado = "inspecionando"
	get_tree().paused = true
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
