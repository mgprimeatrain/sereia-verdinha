class_name Desenhos
extends RefCounted
## Desenhos provisórios feitos com formas simples, centralizados no ponto (0, 0).
## Quando vocês tiverem a pixel art, basta colocar os PNGs na pasta arte/
## que o jogo usa as imagens no lugar destes desenhos.

const CONTORNO := Color("1a1620")
const DOURADO := Color("d4af37")
const PRATA := Color("c0c4cc")

static var _luz: GradientTexture2D


## Textura redonda usada por todas as luzes (lanterna, brilho dos objetos).
static func textura_luz() -> Texture2D:
	if _luz == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.45, Color(1, 1, 1, 0.55))
		_luz = GradientTexture2D.new()
		_luz.gradient = g
		_luz.width = 256
		_luz.height = 256
		_luz.fill = GradientTexture2D.FILL_RADIAL
		_luz.fill_from = Vector2(0.5, 0.5)
		_luz.fill_to = Vector2(1.0, 0.5)
	return _luz


static func elipse(ci: CanvasItem, c: Vector2, rx: float, ry: float, cor: Color) -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	ci.draw_colored_polygon(pts, cor)


## Retângulo com contorno escuro de 1 pixel.
static func caixa(ci: CanvasItem, r: Rect2, cor: Color) -> void:
	ci.draw_rect(r.grow(1), CONTORNO)
	ci.draw_rect(r, cor)


static func desenhar(ci: CanvasItem, forma: String, cor: Color, t: float) -> void:
	match forma:
		"pilha": _pilha(ci, cor)
		"bateria": _bateria(ci, cor)
		"painel": _painel(ci, cor)
		"disco": _disco(ci, cor, t)
		"transistor": _transistor(ci, cor)
		"cpu": _cpu(ci, cor)
		"tela": _tela(ci, cor, t)
		"celular": _celular(ci, cor, t)
		"placa": _placa(ci, cor)
		"inchada": _inchada(ci, cor)
		"pilhas": _pilhas(ci, cor)
		"volta": _volta(ci)
		"valvula": _valvula(ci, cor, t)
		"tv": _tv(ci, cor, t)
		"disquete": _disquete(ci, cor)
		"aviso": _aviso(ci, cor)
		_: caixa(ci, Rect2(-10, -10, 20, 20), cor)


# ---------------------------------------------------------------- personagem

## O Coelho Cientista. O ponto (0, 0) fica nos pés.
static func coelho(ci: CanvasItem, dir: Vector2, passo: float, andando: bool) -> void:
	var pelo := Color("ece4da")
	var rosa := Color("f2a7b5")
	var jaleco := Color("f7f7fb")
	var costas := dir.y < -0.5 and absf(dir.x) < 0.5
	var lado := 0.0
	if absf(dir.x) >= 0.5:
		lado = signf(dir.x)

	var balanco := -absf(sin(passo)) * 1.5 if andando else 0.0
	var o := Vector2(0, balanco)

	elipse(ci, Vector2(0, 0), 8, 2.5, Color(0, 0, 0, 0.35))

	# pés (alternando ao andar)
	var p := sin(passo) * 1.5 if andando else 0.0
	elipse(ci, Vector2(-3, -1 - maxf(p, 0)), 2.6, 1.7, CONTORNO)
	elipse(ci, Vector2(3, -1 - maxf(-p, 0)), 2.6, 1.7, CONTORNO)
	elipse(ci, Vector2(-3, -1.3 - maxf(p, 0)), 2, 1.2, pelo)
	elipse(ci, Vector2(3, -1.3 - maxf(-p, 0)), 2, 1.2, pelo)

	# braços e corpo (jaleco)
	caixa(ci, Rect2(Vector2(-7.5, -12) + o, Vector2(2, 6)), jaleco)
	caixa(ci, Rect2(Vector2(5.5, -12) + o, Vector2(2, 6)), jaleco)
	caixa(ci, Rect2(Vector2(-5.5, -14.5) + o, Vector2(11, 12)), jaleco)
	elipse(ci, Vector2(-6.5, -5.5) + o, 1.5, 1.5, pelo)
	elipse(ci, Vector2(6.5, -5.5) + o, 1.5, 1.5, pelo)
	if costas:
		elipse(ci, Vector2(0, -4) + o, 2.6, 2.6, Color.WHITE)
	elif lado == 0.0:
		ci.draw_rect(Rect2(Vector2(-1.5, -14.5) + o, Vector2(3, 5)), Color("5ab4ff"))
		ci.draw_rect(Rect2(Vector2(-0.5, -8) + o, Vector2(1, 1)), Color("8a8fa0"))
		ci.draw_rect(Rect2(Vector2(-0.5, -5.5) + o, Vector2(1, 1)), Color("8a8fa0"))
	else:
		ci.draw_rect(Rect2(Vector2(lado * 3 - 0.5, -10) + o, Vector2(1, 1)), Color("8a8fa0"))

	# cabeça e orelhas
	var hc := Vector2(lado * 0.5, -20) + o
	var mexe := sin(passo * 0.5) * 0.8 if andando else 0.0
	for s in [-1.0, 1.0]:
		var ec: Vector2 = hc + Vector2(s * 3 + mexe - lado, -8)
		elipse(ci, ec, 2.8, 7, CONTORNO)
		elipse(ci, ec, 2, 6.2, pelo)
		if not costas:
			elipse(ci, ec + Vector2(0, 1), 1, 4.2, rosa)
	elipse(ci, hc, 7.3, 6.3, CONTORNO)
	elipse(ci, hc, 6.5, 5.5, pelo)

	# óculos de proteção na testa
	ci.draw_rect(Rect2(hc + Vector2(-6.5, -4.5), Vector2(13, 1.5)), Color("3a3f55"))
	if costas:
		return
	if lado == 0.0:
		elipse(ci, hc + Vector2(-2.6, -3.8), 2, 1.6, Color("7fe0ff"))
		elipse(ci, hc + Vector2(2.6, -3.8), 2, 1.6, Color("7fe0ff"))
		ci.draw_rect(Rect2(hc + Vector2(-3, -0.5), Vector2(1.3, 2)), CONTORNO)
		ci.draw_rect(Rect2(hc + Vector2(1.7, -0.5), Vector2(1.3, 2)), CONTORNO)
		elipse(ci, hc + Vector2(0, 2), 1.1, 0.8, rosa)
		elipse(ci, hc + Vector2(-4.2, 2), 1.2, 0.8, Color(rosa, 0.6))
		elipse(ci, hc + Vector2(4.2, 2), 1.2, 0.8, Color(rosa, 0.6))
	else:
		elipse(ci, hc + Vector2(lado * 3, -3.8), 2, 1.6, Color("7fe0ff"))
		ci.draw_rect(Rect2(hc + Vector2(lado * 3 - 0.6, -0.5), Vector2(1.3, 2)), CONTORNO)
		elipse(ci, hc + Vector2(lado * 6.3, 1.8), 1, 0.8, rosa)
		elipse(ci, hc + Vector2(lado * 2, 2.2), 1.2, 0.8, Color(rosa, 0.6))


# ---------------------------------------------------------------- componentes

static func _pilha(ci: CanvasItem, cor: Color) -> void:
	caixa(ci, Rect2(-5, -12, 10, 24), cor)
	ci.draw_rect(Rect2(-5, -12, 10, 8), Color("2b2b2b"))
	ci.draw_rect(Rect2(-2, -14, 4, 2), PRATA)
	ci.draw_rect(Rect2(-5, 10, 10, 2), PRATA)
	ci.draw_rect(Rect2(-4, -11, 2, 20), Color(1, 1, 1, 0.3))
	ci.draw_rect(Rect2(-2, 0, 4, 1), Color(0, 0, 0, 0.4))
	ci.draw_rect(Rect2(-0.5, -1.5, 1, 4), Color(0, 0, 0, 0.4))


static func _bateria(ci: CanvasItem, cor: Color) -> void:
	ci.draw_rect(Rect2(-6, -14, 3, 2), DOURADO)
	ci.draw_rect(Rect2(3, -14, 3, 2), DOURADO)
	caixa(ci, Rect2(-9, -12, 18, 24), cor)
	ci.draw_rect(Rect2(-7, -7, 14, 11), Color(1, 1, 1, 0.85))
	ci.draw_rect(Rect2(-5, -5, 10, 1), cor)
	ci.draw_rect(Rect2(-5, -2, 7, 1), cor)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(1, 6), Vector2(-2, 9), Vector2(0, 9), Vector2(-1, 11), Vector2(2, 8), Vector2(0, 8)]), Color("ffe066"))


static func _painel(ci: CanvasItem, cor: Color) -> void:
	ci.draw_rect(Rect2(-1, 8, 2, 5), Color("666a75"))
	ci.draw_rect(Rect2(-5, 12, 10, 2), Color("666a75"))
	caixa(ci, Rect2(-15, -10, 30, 19), PRATA)
	ci.draw_rect(Rect2(-14, -9, 28, 17), cor)
	for i in range(1, 4):
		ci.draw_line(Vector2(-14 + i * 7, -9), Vector2(-14 + i * 7, 8), Color(1, 1, 1, 0.3))
	ci.draw_line(Vector2(-14, -0.5), Vector2(14, -0.5), Color(1, 1, 1, 0.3))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-12, -9), Vector2(-8, -9), Vector2(-13, 0), Vector2(-14, 0), Vector2(-14, -5)]), Color(1, 1, 1, 0.25))


static func _disco(ci: CanvasItem, cor: Color, t: float) -> void:
	elipse(ci, Vector2.ZERO, 14.5, 14.5, CONTORNO)
	elipse(ci, Vector2.ZERO, 13.5, 13.5, Color("d8d8e8"))
	elipse(ci, Vector2.ZERO, 12.5, 12.5, cor)
	for x in range(-12, 12, 4):
		for y in range(-12, 12, 4):
			if Vector2(x + 1.5, y + 1.5).length() < 10.5:
				var brilho := 0.2 + 0.2 * sin(t * 2.0 + x * 0.35 + y * 0.2)
				ci.draw_rect(Rect2(x, y, 3, 3), cor.lightened(brilho))
	ci.draw_rect(Rect2(-4, 12.5, 8, 2), CONTORNO)


static func _transistor(ci: CanvasItem, cor: Color) -> void:
	for x in [-3.5, 0.0, 3.5]:
		ci.draw_line(Vector2(x, 2), Vector2(x, 13), PRATA, 1.0)
	elipse(ci, Vector2(0, -7), 6.5, 5.5, CONTORNO)
	ci.draw_rect(Rect2(-6.5, -7, 13, 10.5), CONTORNO)
	elipse(ci, Vector2(0, -7), 5.5, 4.5, Color("2a2a2e"))
	ci.draw_rect(Rect2(-5.5, -7, 11, 9.5), Color("2a2a2e"))
	ci.draw_rect(Rect2(-3, -4, 6, 1), Color("8a8a90"))
	ci.draw_rect(Rect2(-3, -2, 4, 1), Color("8a8a90"))
	ci.draw_rect(Rect2(-4.5, -10, 2, 10), Color(1, 1, 1, 0.12))
	elipse(ci, Vector2(0, -15), 1.5, 1.5, cor)


static func _cpu(ci: CanvasItem, cor: Color) -> void:
	for i in 6:
		var p := -10.5 + i * 4.0
		ci.draw_rect(Rect2(p, -14, 1.5, 3), cor)
		ci.draw_rect(Rect2(p, 11, 1.5, 3), cor)
		ci.draw_rect(Rect2(-14, p, 3, 1.5), cor)
		ci.draw_rect(Rect2(11, p, 3, 1.5), cor)
	caixa(ci, Rect2(-11, -11, 22, 22), Color("1f6b3a"))
	caixa(ci, Rect2(-7, -7, 14, 14), PRATA)
	ci.draw_rect(Rect2(-4, -2, 8, 1), Color("8a8a90"))
	ci.draw_rect(Rect2(-4, 1, 5, 1), Color("8a8a90"))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-10, 10), Vector2(-10, 7), Vector2(-7, 10)]), cor)


static func _tela(ci: CanvasItem, cor: Color, t: float) -> void:
	ci.draw_rect(Rect2(-2, 7, 4, 4), Color("333338"))
	ci.draw_rect(Rect2(-7, 11, 14, 2), Color("333338"))
	caixa(ci, Rect2(-14, -12, 28, 19), Color("1a1a1e"))
	ci.draw_rect(Rect2(-12, -10, 24, 15), cor.darkened(0.25))
	ci.draw_rect(Rect2(-12, -10, 24, 6), cor)
	ci.draw_rect(Rect2(-12, -4, 24, 3), cor.lightened(0.2))
	var x := -12.0 + fmod(t * 10.0, 24.0)
	ci.draw_rect(Rect2(x, -10, 2, 15), Color(1, 1, 1, 0.25))


static func _celular(ci: CanvasItem, cor: Color, t: float) -> void:
	caixa(ci, Rect2(-7, -13, 14, 26), Color("15151a"))
	ci.draw_rect(Rect2(-5.5, -11, 11, 20), cor.darkened(0.2))
	for i in 3:
		for j in 2:
			ci.draw_rect(Rect2(-4 + j * 5, -9 + i * 5, 3, 3), Color(1, 1, 1, 0.55))
	ci.draw_rect(Rect2(-1.5, 10.5, 3, 1), Color("55555f"))
	var r := fmod(t * 4.0, 4.0)
	ci.draw_arc(Vector2(1.5, 4), 1 + r, 0, TAU, 16, Color(1, 1, 1, 1.0 - r / 4.0), 1.0)


static func _placa(ci: CanvasItem, cor: Color) -> void:
	caixa(ci, Rect2(-14, -10, 28, 20), cor)
	var trilha := Color(DOURADO, 0.85)
	ci.draw_polyline(PackedVector2Array([Vector2(-12, -6), Vector2(-1, -6), Vector2(3, -2)]), trilha, 1.0)
	ci.draw_polyline(PackedVector2Array([Vector2(-12, 5), Vector2(-5, 5), Vector2(-5, 8)]), trilha, 1.0)
	ci.draw_polyline(PackedVector2Array([Vector2(5, 7), Vector2(12, 7)]), trilha, 1.0)
	ci.draw_rect(Rect2(-9, -3, 8, 6), Color("1a1a1e"))
	ci.draw_rect(Rect2(4, -8, 7, 5), Color("1a1a1e"))
	elipse(ci, Vector2(7, 2), 2.5, 2.5, Color("3050c0"))
	for c in [Vector2(-12, -8), Vector2(12, -8), Vector2(-12, 8), Vector2(12, 8)]:
		elipse(ci, c, 1, 1, Color("e0d080"))
	ci.draw_rect(Rect2(8, -10, 3, 3), Color("2a2418"))


static func _inchada(ci: CanvasItem, cor: Color) -> void:
	ci.draw_rect(Rect2(-6, -15, 3, 2), DOURADO)
	ci.draw_rect(Rect2(3, -15, 3, 2), DOURADO)
	elipse(ci, Vector2.ZERO, 11.5, 13.5, CONTORNO)
	elipse(ci, Vector2.ZERO, 10.5, 12.5, cor)
	elipse(ci, Vector2(-4, -5), 3, 4, Color(1, 1, 1, 0.35))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(0, -4), Vector2(5.5, 6), Vector2(-5.5, 6)]), CONTORNO)
	ci.draw_rect(Rect2(-0.5, -1, 1, 4), Color("ffe066"))
	ci.draw_rect(Rect2(-0.5, 4, 1, 1), Color("ffe066"))


static func _pilhas(ci: CanvasItem, cor: Color) -> void:
	elipse(ci, Vector2(0, 12), 13, 2.5, Color("9bbf3a", 0.6))
	var cores := [cor, Color("4a6fa5"), Color("a54a4a")]
	for i in 3:
		var x := -10.0 + i * 7.0
		var h := 18.0 - i * 3.0
		var y0 := 12.0 - h
		caixa(ci, Rect2(x, y0, 6, h), cores[i])
		ci.draw_rect(Rect2(x, y0, 6, 4), Color("2b2b2b"))
		ci.draw_rect(Rect2(x + 2, y0 - 1.5, 2, 1.5), PRATA)


static func _volta(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(-11, -13, 1.5, 24), Color(0.7, 0.85, 0.95, 0.6))
	ci.draw_rect(Rect2(9.5, -13, 1.5, 24), Color(0.7, 0.85, 0.95, 0.6))
	caixa(ci, Rect2(-12, 10, 24, 3), Color("6b4a2b"))
	var camadas := [Color("b87333"), Color("9aa0a6"), Color("7a6a4a")]
	for i in 10:
		ci.draw_rect(Rect2(-7, 8 - i * 2.1, 14, 2), camadas[i % 3])
	ci.draw_polyline(PackedVector2Array([Vector2(0, -13), Vector2(-3, -16), Vector2(-8, -16)]), Color("e05a5a"), 1.0)


static func _valvula(ci: CanvasItem, cor: Color, t: float) -> void:
	for x in [-3.0, 0.0, 3.0]:
		ci.draw_line(Vector2(x, 12), Vector2(x, 15), PRATA, 1.0)
	caixa(ci, Rect2(-6, 7, 12, 5), Color("2a2a2e"))
	var vidro := Color(0.75, 0.9, 1.0, 0.25)
	elipse(ci, Vector2(0, -4), 8, 9, vidro)
	ci.draw_rect(Rect2(-8, -4, 16, 11), vidro)
	ci.draw_rect(Rect2(-3, -7, 6, 11), Color("707078"))
	var forca := 0.7 + 0.3 * sin(t * 9.0)
	elipse(ci, Vector2(0, -1), 6, 6, Color(cor, 0.3 * forca))
	ci.draw_polyline(PackedVector2Array([Vector2(-2, 4), Vector2(-1, -5), Vector2(1, 4), Vector2(2, -5)]), Color(1, 0.75, 0.3, forca), 1.0)
	ci.draw_rect(Rect2(-6, -10, 2, 12), Color(1, 1, 1, 0.3))


static func _tv(ci: CanvasItem, cor: Color, t: float) -> void:
	ci.draw_line(Vector2(-2, -12), Vector2(-8, -20), Color("8a8a90"), 1.0)
	ci.draw_line(Vector2(2, -12), Vector2(8, -20), Color("8a8a90"), 1.0)
	ci.draw_rect(Rect2(-10, 10, 2, 3), Color("3a2a1a"))
	ci.draw_rect(Rect2(8, 10, 2, 3), Color("3a2a1a"))
	caixa(ci, Rect2(-14, -12, 28, 22), Color("7a5530"))
	ci.draw_rect(Rect2(-12, -10, 19, 18), Color("1e1e22"))
	var pisca := 0.85 + 0.15 * sin(t * 25.0)
	ci.draw_rect(Rect2(-11, -9, 17, 16), Color(cor.darkened(0.2), pisca))
	for y in range(-9, 7, 2):
		ci.draw_line(Vector2(-11, y), Vector2(6, y), Color(0, 0, 0, 0.18))
	for c in [Vector2(-11, -9), Vector2(5, -9), Vector2(-11, 6), Vector2(5, 6)]:
		ci.draw_rect(Rect2(c, Vector2(1, 1)), Color("1e1e22"))
	elipse(ci, Vector2(10.5, -6), 1.6, 1.6, PRATA)
	elipse(ci, Vector2(10.5, -1.5), 1.6, 1.6, PRATA)
	for y in range(2, 8, 2):
		ci.draw_line(Vector2(9, y), Vector2(12, y), Color("3a2a1a"))


static func _disquete(ci: CanvasItem, cor: Color) -> void:
	caixa(ci, Rect2(-11, -11, 22, 22), cor)
	ci.draw_rect(Rect2(-6, -11, 12, 8), PRATA)
	ci.draw_rect(Rect2(1.5, -9.5, 2.5, 5), Color("2a2a2e"))
	ci.draw_rect(Rect2(-8, 0, 16, 10), Color("f0f0f0"))
	ci.draw_rect(Rect2(-6, 3, 12, 1), Color(cor, 0.7))
	ci.draw_rect(Rect2(-6, 6, 8, 1), Color(cor, 0.7))
	ci.draw_rect(Rect2(-10, 8, 1.5, 1.5), Color("15151a"))


static func _aviso(ci: CanvasItem, cor: Color) -> void:
	caixa(ci, Rect2(-1.5, 2, 3, 12), Color("6b4a2b"))
	caixa(ci, Rect2(-13, -12, 26, 15), Color("8a6a40"))
	ci.draw_rect(Rect2(-11, -10, 22, 11), cor)
	var tinta := Color("5a4020")
	ci.draw_rect(Rect2(-9, -8, 18, 1.5), tinta)
	ci.draw_rect(Rect2(-9, -5, 13, 1.5), tinta)
	ci.draw_rect(Rect2(-9, -2, 16, 1.5), tinta)
