class_name Sala
extends Node2D
## Monta uma sala a partir de Dados.SALAS: chão, paredes, portas e objetos.

signal porta_tocada(destino: String)

const PAREDE := 16
const TOPO := 40
const LARGURA_PORTA := 28
const PARA_DENTRO := {
	"cima": Vector2(0, 1), "baixo": Vector2(0, -1),
	"esquerda": Vector2(1, 0), "direita": Vector2(-1, 0),
}

var id := ""
var dados: Dictionary
var tamanho := Vector2.ZERO
var cor := Color.WHITE
var objetos: Array[Inspecionavel] = []
var chao: Node2D
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
	escuridao.configurar(tamanho, dados["ambiente"])
	add_child(escuridao)

	_criar_paredes()
	for lado in dados["portas"]:
		_criar_porta(lado, dados["portas"][lado])
	for item in dados["objetos"]:
		var objeto := Inspecionavel.new()
		objeto.configurar(item[0])
		objeto.position = item[1]
		add_child(objeto)
		objetos.append(objeto)
		escuridao.adicionar_luz(objeto.position + Vector2(0, -20), 70, 0.8)


## Ponto na borda interna da parede, no meio da porta.
func posicao_porta(lado: String) -> Vector2:
	match lado:
		"cima": return Vector2(tamanho.x / 2, TOPO)
		"baixo": return Vector2(tamanho.x / 2, tamanho.y - PAREDE)
		"esquerda": return Vector2(PAREDE, tamanho.y / 2 + 12)
		_: return Vector2(tamanho.x - PAREDE, tamanho.y / 2 + 12)


## Onde o coelho aparece ao chegar vindo da sala "origem".
func ponto_chegada(origem: String) -> Vector2:
	for lado in dados["portas"]:
		if dados["portas"][lado] == origem:
			return posicao_porta(lado) + PARA_DENTRO[lado] * 30
	return Vector2(tamanho.x / 2, tamanho.y / 2 + 70)


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
		var forma := CollisionShape2D.new()
		var ret := RectangleShape2D.new()
		ret.size = r.size
		forma.shape = ret
		forma.position = r.get_center()
		corpo.add_child(forma)
	add_child(corpo)


func _criar_porta(lado: String, destino: String) -> void:
	var dentro: Vector2 = PARA_DENTRO[lado]
	var p := posicao_porta(lado)

	var area := Area2D.new()
	var forma := CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = Vector2(LARGURA_PORTA, 10) if dentro.x == 0 else Vector2(10, LARGURA_PORTA)
	forma.shape = ret
	area.add_child(forma)
	area.position = p + dentro * 3
	area.body_entered.connect(_corpo_na_porta.bind(destino))
	add_child(area)

	var luz := Escuridao.brilho(cor, 32, 0.3)
	luz.position = p + dentro * 10
	add_child(luz)
	escuridao.adicionar_luz(p + dentro * 10, 60, 0.7)

	var placa := Label.new()
	placa.text = Dados.SALAS[destino]["curto"]
	placa.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placa.add_theme_font_size_override("font_size", 8)
	placa.add_theme_color_override("font_color", cor.lightened(0.5))
	placa.add_theme_constant_override("outline_size", 3)
	placa.add_theme_color_override("font_outline_color", Color("10101a"))
	placa.size = Vector2(90, 12)
	placa.z_index = 55
	# placas em cima/embaixo ficam na própria parede; nas laterais, abaixo da porta
	var centro: Vector2
	if dentro.y > 0:
		centro = Vector2(p.x, 6)
	elif dentro.y < 0:
		centro = Vector2(p.x, tamanho.y - 8)
	else:
		centro = p + Vector2(dentro.x * 36, 26)
	placa.position = centro - placa.size / 2
	add_child(placa)


func _corpo_na_porta(corpo: Node2D, destino: String) -> void:
	if corpo is Jogador:
		porta_tocada.emit(destino)


func _desenhar_chao() -> void:
	var w := tamanho.x
	var h := tamanho.y
	var c1: Color = dados["chao"][0]
	var c2: Color = dados["chao"][1]
	var parede: Color = dados["parede"]

	# piso quadriculado
	for x in range(0, int(w), 16):
		for y in range(0, int(h), 16):
			chao.draw_rect(Rect2(x, y, 16, 16), c1 if (x + y) / 16 % 2 == 0 else c2)
	var junta := Color(0, 0, 0, 0.12)
	for x in range(0, int(w), 16):
		chao.draw_line(Vector2(x, 0), Vector2(x, h), junta)
	for y in range(0, int(h), 16):
		chao.draw_line(Vector2(0, y), Vector2(w, y), junta)

	# sujeirinhas e parafusos (sempre no mesmo lugar para cada sala)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id)
	for i in 40:
		var pos := Vector2(rng.randf_range(20, w - 20), rng.randf_range(TOPO + 4, h - 20)).floor()
		var tom := Color(0, 0, 0, 0.18) if rng.randf() < 0.7 else Color(1, 1, 1, 0.08)
		chao.draw_rect(Rect2(pos, Vector2(rng.randi_range(1, 3), 1)), tom)

	# tapete com a cor da sala
	var tapete := Rect2(64, TOPO + 40, w - 128, h - TOPO - 96)
	chao.draw_rect(tapete, Color(cor, 0.08))
	chao.draw_rect(tapete, Color(cor, 0.25), false, 1.0)

	# paredes
	chao.draw_rect(Rect2(0, TOPO, w, 6), Color(0, 0, 0, 0.3))
	chao.draw_rect(Rect2(0, 0, w, TOPO), parede)
	var frente := parede.lightened(0.12)
	chao.draw_rect(Rect2(0, 14, w, TOPO - 14), frente)
	for x in range(0, int(w), 32):
		chao.draw_line(Vector2(x, 14), Vector2(x, TOPO), parede.darkened(0.2))
	chao.draw_rect(Rect2(0, TOPO - 4, w, 2), Color(cor, 0.5))
	chao.draw_rect(Rect2(0, 13, w, 1), parede.lightened(0.3))

	# quadros na parede
	for x in range(56, int(w) - 40, 112):
		if absf(x + 8 - w / 2) < 40:
			continue
		chao.draw_rect(Rect2(x - 1, 17, 18, 13), Color("15151a"))
		chao.draw_rect(Rect2(x, 18, 16, 11), cor.darkened(0.45))
		chao.draw_rect(Rect2(x + 3, 21, 10, 1), Color(cor, 0.8))
		chao.draw_rect(Rect2(x + 3, 24, 6, 1), Color(cor, 0.6))

	chao.draw_rect(Rect2(0, h - PAREDE, w, PAREDE), parede)
	chao.draw_rect(Rect2(0, 0, PAREDE, h), parede)
	chao.draw_rect(Rect2(w - PAREDE, 0, PAREDE, h), parede)
	chao.draw_rect(Rect2(0, h - PAREDE, w, 1), parede.lightened(0.25))
	chao.draw_rect(Rect2(PAREDE - 1, TOPO, 1, h - TOPO - PAREDE), parede.lightened(0.25))
	chao.draw_rect(Rect2(w - PAREDE, TOPO, 1, h - TOPO - PAREDE), parede.lightened(0.25))

	# portas
	var escuro := Color("08080c")
	for lado in dados["portas"]:
		var p := posicao_porta(lado)
		var meio := LARGURA_PORTA / 2.0
		var vao: Rect2
		match lado:
			"cima": vao = Rect2(p.x - meio, 12, LARGURA_PORTA, TOPO - 12)
			"baixo": vao = Rect2(p.x - meio, h - PAREDE, LARGURA_PORTA, PAREDE)
			"esquerda": vao = Rect2(0, p.y - meio, PAREDE, LARGURA_PORTA)
			_: vao = Rect2(w - PAREDE, p.y - meio, PAREDE, LARGURA_PORTA)
		chao.draw_rect(vao.grow(2), cor.darkened(0.3))
		chao.draw_rect(vao, escuro)
		var dentro: Vector2 = PARA_DENTRO[lado]
		var brilho := Rect2(p - Vector2(meio, meio) + dentro * meio, Vector2(LARGURA_PORTA, LARGURA_PORTA))
		chao.draw_rect(brilho, Color(cor, 0.1))
