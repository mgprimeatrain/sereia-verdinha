class_name Sala
extends Node2D
## Monta uma sala a partir de Dados.SALAS: chão, paredes, portas, móveis e objetos.

signal porta_tocada(destino: String)

const PAREDE := 12
const TOPO := 64
const LARGURA_PORTA := 28
const PARA_DENTRO := {
	"cima": Vector2(0, 1), "baixo": Vector2(0, -1),
	"esquerda": Vector2(1, 0), "direita": Vector2(-1, 0),
}
const NA_PAREDE := ["quadro", "janela", "tabela"]
const NO_CHAO := ["cabos"]

var id := ""
var dados: Dictionary
var tamanho := Vector2.ZERO
var cor := Color.WHITE
var objetos: Array[Inspecionavel] = []
var chao: Node2D
var parede: Node2D
var escuridao: Escuridao


func configurar(id_sala: String) -> void:
	id = id_sala
	dados = Dados.SALAS[id]
	tamanho = dados["tamanho"]
	cor = dados["cor"]
	y_sort_enabled = true

	chao = Node2D.new()
	chao.z_index = -10
	chao.draw.connect(_desenhar_chao)
	add_child(chao)

	escuridao = Escuridao.new()
	escuridao.configurar(tamanho)
	add_child(escuridao)

	_criar_paredes()
	for lado in dados["portas"]:
		_criar_porta(lado, dados["portas"][lado])
	for item in dados["moveis"]:
		_criar_movel(item[0], item[1])
	for item in dados["objetos"]:
		var objeto := Inspecionavel.new()
		objeto.configurar(item[0])
		objeto.position = item[1]
		add_child(objeto)
		objetos.append(objeto)
		escuridao.adicionar_luz(objeto.position + Vector2(0, -20), 55, 0.55)


## Ponto na borda interna da parede, no meio da porta.
func posicao_porta(lado: String) -> Vector2:
	var meio_y := roundf((TOPO + tamanho.y - PAREDE) / 2.0)
	match lado:
		"cima": return Vector2(tamanho.x / 2, TOPO)
		"baixo": return Vector2(tamanho.x / 2, tamanho.y - PAREDE)
		"esquerda": return Vector2(PAREDE, meio_y)
		_: return Vector2(tamanho.x - PAREDE, meio_y)


## Onde o coelho aparece ao chegar vindo da sala "origem".
func ponto_chegada(origem: String) -> Vector2:
	for lado in dados["portas"]:
		if dados["portas"][lado] == origem:
			return posicao_porta(lado) + PARA_DENTRO[lado] * 30
	return Vector2(tamanho.x / 2, tamanho.y - 60)


func direcao_chegada(origem: String) -> Vector2:
	for lado in dados["portas"]:
		if dados["portas"][lado] == origem:
			return PARA_DENTRO[lado]
	return Vector2.DOWN


func _criar_paredes() -> void:
	var corpo := StaticBody2D.new()
	for r in [
		Rect2(0, 0, tamanho.x, TOPO),
		Rect2(0, tamanho.y - PAREDE, tamanho.x, PAREDE),
		Rect2(0, 0, PAREDE, tamanho.y),
		Rect2(tamanho.x - PAREDE, 0, PAREDE, tamanho.y),
	]:
		_adicionar_forma(corpo, r.size, r.get_center())
	add_child(corpo)


func _adicionar_forma(corpo: CollisionObject2D, tam: Vector2, pos: Vector2) -> void:
	var forma := CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = tam
	forma.shape = ret
	forma.position = pos
	corpo.add_child(forma)


func _criar_movel(tipo: String, pos: Vector2) -> void:
	var movel := Movel.new()
	movel.tipo = tipo
	if tipo in NA_PAREDE:
		movel.position = Vector2(pos.x, TOPO - 14)
		movel.z_index = -5
	elif tipo in NO_CHAO:
		movel.position = pos
		movel.z_index = -6
	else:
		movel.position = pos
		var largura := Desenhos.largura_movel(tipo)
		var corpo := StaticBody2D.new()
		_adicionar_forma(corpo, Vector2(largura, 8), Vector2(0, -4))
		movel.add_child(corpo)
	add_child(movel)

	var luz := Desenhos.luz_movel(tipo)
	if luz != Vector3.ZERO:
		var centro := movel.position + Vector2(0, luz.x)
		escuridao.adicionar_luz(centro, luz.y, luz.z)
		var brilho := Escuridao.brilho(Color(1.0, 0.55, 0.2), luz.y * 0.8, 0.22)
		brilho.position = Vector2(0, luz.x)
		movel.add_child(brilho)
	if tipo == "janela":
		escuridao.adicionar_luz(Vector2(pos.x, TOPO + 20), 50, 0.35)


func _criar_porta(lado: String, destino: String) -> void:
	var dentro: Vector2 = PARA_DENTRO[lado]
	var p := posicao_porta(lado)

	var area := Area2D.new()
	_adicionar_forma(area, Vector2(LARGURA_PORTA, 10) if dentro.x == 0 else Vector2(10, LARGURA_PORTA), Vector2.ZERO)
	area.position = p + dentro * 3
	area.body_entered.connect(_corpo_na_porta.bind(destino))
	add_child(area)

	escuridao.adicionar_luz(p + dentro * 8, 40, 0.45)

	var placa := Label.new()
	placa.text = Dados.SALAS[destino]["curto"]
	placa.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placa.add_theme_font_size_override("font_size", 8)
	placa.add_theme_color_override("font_color", Color("e8d2a8"))
	placa.add_theme_constant_override("outline_size", 3)
	placa.add_theme_color_override("font_outline_color", Color("0c0806"))
	placa.size = Vector2(90, 12)
	placa.z_index = 55
	var centro: Vector2
	if dentro.y > 0:
		centro = Vector2(p.x, 7)
	elif dentro.y < 0:
		centro = Vector2(p.x, tamanho.y - 6)
	else:
		centro = p + Vector2(dentro.x * 36, 26)
	placa.position = centro - placa.size / 2
	add_child(placa)


func _corpo_na_porta(corpo: Node2D, destino: String) -> void:
	if corpo is Jogador:
		porta_tocada.emit(destino)


# ------------------------------------------------------------------ desenho

func _desenhar_chao() -> void:
	var w := tamanho.x
	var h := tamanho.y
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id)
	var madeira: Color = dados["madeira"]

	# tábuas de madeira
	for y in range(TOPO, int(h), 7):
		var x := -rng.randi_range(0, 40)
		while x < w:
			var comprimento := rng.randi_range(36, 70)
			var tom := madeira.lightened(rng.randf_range(-0.12, 0.1))
			chao.draw_rect(Rect2(x, y, comprimento, 7), tom)
			chao.draw_rect(Rect2(x, y, comprimento, 1), tom.lightened(0.08))
			chao.draw_rect(Rect2(x, y + 6, comprimento, 1), madeira.darkened(0.5))
			chao.draw_rect(Rect2(x + comprimento - 1, y, 1, 7), madeira.darkened(0.55))
			for i in 2:
				var vx := x + rng.randi_range(3, comprimento - 8)
				chao.draw_rect(Rect2(vx, y + rng.randi_range(2, 4), rng.randi_range(3, 8), 1), tom.darkened(0.18))
			x += comprimento

	# manchas no chão
	for i in 14:
		var pos := Vector2(rng.randf_range(30, w - 30), rng.randf_range(TOPO + 20, h - 30))
		Desenhos.elipse(chao, pos, rng.randf_range(6, 16), rng.randf_range(3, 7), Color(0, 0, 0, 0.18))

	# tapete
	var tapete: Color = dados["tapete"]
	if tapete.a > 0:
		var r := Rect2(w / 2 - 70, TOPO + 56, 140, h - TOPO - 130).abs()
		chao.draw_rect(r, tapete)
		chao.draw_rect(r.grow(-4), tapete.darkened(0.25), false, 2.0)
		chao.draw_rect(r.grow(-8), tapete.lightened(0.12), false, 1.0)
		for x in range(int(r.position.x) + 12, int(r.end.x) - 8, 12):
			Desenhos.elipse(chao, Vector2(x, r.position.y + 3), 1.5, 1.5, tapete.lightened(0.2))
			Desenhos.elipse(chao, Vector2(x, r.end.y - 3), 1.5, 1.5, tapete.lightened(0.2))

	# sombra da parede no chão
	chao.draw_rect(Rect2(0, TOPO, w, 10), Color(0, 0, 0, 0.25))
	chao.draw_rect(Rect2(0, TOPO, w, 4), Color(0, 0, 0, 0.3))

	# parede do fundo: papel de parede velho
	var papel: Color = dados["papel"]
	chao.draw_rect(Rect2(0, 0, w, TOPO), papel)
	for x in range(0, int(w), 12):
		chao.draw_rect(Rect2(x, 8, 6, TOPO - 18), papel.lightened(0.05))
		for y in range(14, TOPO - 14, 12):
			chao.draw_rect(Rect2(x + 2 + (y / 12 % 2) * 6, y, 2, 2), papel.lightened(0.1))
	for i in 10:
		var pos := Vector2(rng.randf_range(10, w - 10), rng.randf_range(14, TOPO - 16))
		Desenhos.elipse(chao, pos, rng.randf_range(5, 14), rng.randf_range(4, 10), Color(0, 0, 0, 0.22))
		chao.draw_rect(Rect2(pos.x, pos.y, 1, rng.randf_range(6, 16)), Color(0, 0, 0, 0.2))
	chao.draw_rect(Rect2(0, 0, w, 8), papel.darkened(0.6))
	chao.draw_rect(Rect2(0, 8, w, 2), papel.darkened(0.3))
	chao.draw_rect(Rect2(0, TOPO - 10, w, 10), Color("2a1a10"))
	chao.draw_rect(Rect2(0, TOPO - 10, w, 1), Color("4a3020"))

	# teias de aranha nos cantos
	_teia(Vector2(PAREDE, 8), 1)
	_teia(Vector2(w - PAREDE, 8), -1)

	# paredes laterais e de baixo
	var escuro := Color("140c08")
	chao.draw_rect(Rect2(0, h - PAREDE, w, PAREDE), escuro)
	chao.draw_rect(Rect2(0, 0, PAREDE, h), escuro)
	chao.draw_rect(Rect2(w - PAREDE, 0, PAREDE, h), escuro)
	chao.draw_rect(Rect2(PAREDE - 2, TOPO, 2, h - TOPO - PAREDE), Color("3a2414"))
	chao.draw_rect(Rect2(w - PAREDE, TOPO, 2, h - TOPO - PAREDE), Color("3a2414"))
	chao.draw_rect(Rect2(0, h - PAREDE, w, 2), Color("3a2414"))

	# portas
	for lado in dados["portas"]:
		var p := posicao_porta(lado)
		var meio := LARGURA_PORTA / 2.0
		var vao: Rect2
		match lado:
			"cima": vao = Rect2(p.x - meio, 16, LARGURA_PORTA, TOPO - 16)
			"baixo": vao = Rect2(p.x - meio, h - PAREDE, LARGURA_PORTA, PAREDE)
			"esquerda": vao = Rect2(0, p.y - meio, PAREDE, LARGURA_PORTA)
			_: vao = Rect2(w - PAREDE, p.y - meio, PAREDE, LARGURA_PORTA)
		chao.draw_rect(vao.grow(3), Color("2a1a10"))
		chao.draw_rect(vao.grow(2), Color("5a3a22"))
		chao.draw_rect(vao, Color("050303"))


func _teia(canto: Vector2, lado: float) -> void:
	var fio := Color(0.8, 0.75, 0.7, 0.25)
	for i in 4:
		var a := deg_to_rad(10 + i * 25)
		chao.draw_line(canto, canto + Vector2(cos(a) * lado, sin(a)) * 18, fio)
	for r in [6.0, 11.0, 16.0]:
		var pts := PackedVector2Array()
		for i in 4:
			var a := deg_to_rad(10 + i * 25)
			pts.append(canto + Vector2(cos(a) * lado, sin(a)) * r)
		chao.draw_polyline(pts, fio)
