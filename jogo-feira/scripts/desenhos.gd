class_name Desenhos
extends RefCounted
## Desenhos provisórios feitos com formas simples, centralizados no ponto (0, 0).
## Quando vocês tiverem a pixel art, basta colocar os PNGs na pasta arte/
## que o jogo usa as imagens no lugar destes desenhos.

const CONTORNO := Color("111015")
const DOURADO := Color("d4af37")
const PRATA := Color("c0c4cc")
const SOMBRA := Color(0.16, 0.12, 0.22, 0.38)

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

## Cores do coelho: troque aqui para ficar igual ao seu coelho!
const PELO := Color("ece4da")
const PELO_SOMBRA := Color("b8aa9c")
const ROSA := Color("e8909c")
const OLHO := Color("2a1410")
const JALECO := Color("e8e4dc")
const JALECO_SOMBRA := Color("a8a49c")
const ORELHAS_CAIDAS := false


## O Coelho Cientista, cabeçudo como nos jogos estilo Enigma do Medo.
## O ponto (0, 0) fica nos pés.
static func coelho(ci: CanvasItem, dir: Vector2, passo: float, andando: bool) -> void:
	var costas := dir.y < -0.5 and absf(dir.x) < 0.5
	var lado := 0.0
	if absf(dir.x) >= 0.5:
		lado = signf(dir.x)
	var o := Vector2(0, -absf(sin(passo)) * 1.2 if andando else 0.0)


	# pés
	var p := sin(passo) * 1.5 if andando else 0.0
	for s in [-1.0, 1.0]:
		var pe := Vector2(s * 3.5, -1.2 - maxf(p * s, 0.0))
		elipse(ci, pe, 3.2, 2.2, CONTORNO)
		elipse(ci, pe + Vector2(0, -0.3), 2.4, 1.5, PELO)

	# braços
	for s in [-1.0, 1.0]:
		var braco := Vector2(s * 7.2, -8.5) + o
		elipse(ci, braco, 2.6, 4.6, CONTORNO)
		elipse(ci, braco, 1.8, 3.8, JALECO if s < 0 else JALECO_SOMBRA)
		elipse(ci, braco + Vector2(0, 3.8), 1.7, 1.5, PELO)

	# corpo com jaleco
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(-7, -14.5) + o, Vector2(7, -14.5) + o, Vector2(8.8, -1) + o, Vector2(-8.8, -1) + o]), CONTORNO)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(-6, -13.5) + o, Vector2(6, -13.5) + o, Vector2(7.6, -2) + o, Vector2(-7.6, -2) + o]), JALECO)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(3, -13.5) + o, Vector2(6, -13.5) + o, Vector2(7.6, -2) + o, Vector2(4, -2) + o]), JALECO_SOMBRA)
	if costas:
		elipse(ci, Vector2(0, -5) + o, 3, 3, CONTORNO)
		elipse(ci, Vector2(0, -5) + o, 2.3, 2.3, Color.WHITE)
	elif lado == 0.0:
		ci.draw_colored_polygon(PackedVector2Array([Vector2(-2.5, -13.5) + o, Vector2(2.5, -13.5) + o, Vector2(0, -8) + o]), Color("3a5a8a"))
		ci.draw_line(Vector2(0, -8) + o, Vector2(0, -2) + o, JALECO_SOMBRA)
		ci.draw_rect(Rect2(Vector2(-6, -7) + o, Vector2(3, 2)), JALECO_SOMBRA)
		ci.draw_rect(Rect2(Vector2(-5.5, -8.5) + o, Vector2(1, 2)), Color("d1603b"))
	else:
		ci.draw_line(Vector2(lado * 2, -13) + o, Vector2(lado * 3, -2) + o, JALECO_SOMBRA)

	# cabeça grande
	var hc := Vector2(lado * 0.8, -21) + o
	var mexe := sin(passo * 0.5) * 0.8 if andando else 0.0
	for s in [-1.0, 1.0]:
		if ORELHAS_CAIDAS:
			var ec: Vector2 = hc + Vector2(s * 8.2, 2)
			elipse(ci, ec, 3.4, 7.2, CONTORNO)
			elipse(ci, ec, 2.6, 6.4, PELO_SOMBRA if s > 0 else PELO)
		else:
			var ec: Vector2 = hc + Vector2(s * 3.6 + mexe - lado * 1.5, -11)
			elipse(ci, ec, 3.4, 8.6, CONTORNO)
			elipse(ci, ec, 2.6, 7.8, PELO if s < 0 else PELO_SOMBRA)
			if not costas:
				elipse(ci, ec + Vector2(0, 1), 1.2, 5.6, ROSA)
	elipse(ci, hc, 9.8, 8.3, CONTORNO)
	elipse(ci, hc, 9, 7.5, PELO_SOMBRA)
	elipse(ci, hc + Vector2(-0.6, -0.8), 8.2, 6.6, PELO)

	# óculos de proteção na testa
	ci.draw_rect(Rect2(hc + Vector2(-9, -5.8), Vector2(18, 1.8)), Color("3a2e28"))
	if costas:
		return
	if lado == 0.0:
		for s in [-1.0, 1.0]:
			elipse(ci, hc + Vector2(s * 3.4, -5), 2.6, 2.1, Color("3a2e28"))
			elipse(ci, hc + Vector2(s * 3.4, -5), 1.8, 1.4, Color("e8a040"))
			# olhos grandes e brilhantes
			ci.draw_rect(Rect2(hc + Vector2(s * 3.4 - 1.3, -0.8), Vector2(2.6, 3.6)), OLHO)
			ci.draw_rect(Rect2(hc + Vector2(s * 3.4 - 1.3, -0.8), Vector2(1, 1)), Color.WHITE)
			elipse(ci, hc + Vector2(s * 6.2, 3.6), 1.5, 0.9, Color(ROSA, 0.6))
		ci.draw_colored_polygon(PackedVector2Array([hc + Vector2(-1, 3), hc + Vector2(1, 3), hc + Vector2(0, 4.2)]), ROSA)
		ci.draw_line(hc + Vector2(0, 4.2), hc + Vector2(0, 5.2), OLHO)
	else:
		elipse(ci, hc + Vector2(lado * 4, -5), 2.6, 2.1, Color("3a2e28"))
		elipse(ci, hc + Vector2(lado * 4, -5), 1.8, 1.4, Color("e8a040"))
		ci.draw_rect(Rect2(hc + Vector2(lado * 4.2 - 1.3, -0.8), Vector2(2.6, 3.6)), OLHO)
		ci.draw_rect(Rect2(hc + Vector2(lado * 4.2 - (1.3 if lado > 0 else -0.3), -0.8), Vector2(1, 1)), Color.WHITE)
		elipse(ci, hc + Vector2(lado * 8.9, 2.6), 1.1, 0.9, ROSA)
		elipse(ci, hc + Vector2(lado * 4.5, 3.8), 1.5, 0.9, Color(ROSA, 0.6))


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


# ---------------------------------------------------------------- móveis

const MADEIRA := Color("a8805e")
const MADEIRA_ESCURA := Color("7a5a42")


static func largura_movel(tipo: String) -> float:
	match tipo:
		"estante": return 36
		"bancada": return 52
		"armario": return 26
		"caixas": return 28
		"mesa_vela": return 20
		"lampiao": return 10
		"barril": return 18
		"sucata": return 40
	return 16


## Luz de um móvel: (altura da luz, raio, força). Vector3.ZERO = sem luz.
static func luz_movel(tipo: String) -> Vector3:
	match tipo:
		"mesa_vela": return Vector3(-20, 75, 0.95)
		"lampiao": return Vector3(-18, 70, 0.9)
		"bancada": return Vector3(-24, 32, 0.35)
	return Vector3.ZERO


static func _chama(ci: CanvasItem, base: Vector2, t: float, fase: float) -> void:
	var tremida := sin(t * 13.0 + fase) * 0.4 + sin(t * 7.0 + fase * 2.0) * 0.3
	elipse(ci, base + Vector2(tremida * 0.5, -2.5), 1.6, 3.0 + tremida * 0.4, Color("ff8a2a"))
	elipse(ci, base + Vector2(tremida * 0.3, -2), 0.8, 1.6, Color("ffe8a0"))


static func movel(ci: CanvasItem, tipo: String, t: float) -> void:
	match tipo:
		"estante": _estante(ci)
		"bancada": _bancada(ci, t)
		"armario": _armario(ci)
		"caixas": _caixas(ci)
		"mesa_vela": _mesa_vela(ci, t)
		"lampiao": _lampiao(ci, t)
		"cabos": _cabos(ci)
		"barril": _barril(ci, t)
		"sucata": _sucata(ci)
		"quadro": _quadro(ci)
		"janela": _janela(ci)
		"tabela": _tabela(ci)


static func _estante(ci: CanvasItem) -> void:
	elipse(ci, Vector2(2, 0), 22, 4.0, SOMBRA)
	caixa(ci, Rect2(-18, -52, 36, 52), MADEIRA)
	ci.draw_rect(Rect2(-16, -50, 32, 48), Color("1a0f08"))
	var cores := [Color("6a2a20"), Color("2e4a2e"), Color("6a5a2a"), Color("2a3048"), Color("5a3a4a"), Color("7a6a4a")]
	for prateleira in 3:
		var y := -50 + prateleira * 16
		ci.draw_rect(Rect2(-16, y + 14, 32, 2), MADEIRA.lightened(0.1))
		var x := -15.0
		var i := prateleira * 2
		while x < 13:
			var lar := 2.0 + (i * 7 % 3)
			var alt := 9.0 + (i * 5 % 4)
			if prateleira == 1 and i % 3 == 0:
				# vidro com líquido
				ci.draw_rect(Rect2(x, y + 14 - 8, 4, 8), Color(0.8, 0.9, 0.9, 0.3))
				ci.draw_rect(Rect2(x, y + 14 - 4, 4, 4), Color("7fd13b") if i % 2 == 0 else Color("d1603b"))
				lar = 4
			else:
				ci.draw_rect(Rect2(x, y + 14 - alt, lar, alt), cores[i % cores.size()])
				ci.draw_rect(Rect2(x, y + 14 - alt + 2, lar, 1), Color(1, 1, 1, 0.12))
			x += lar + 1
			i += 1
	ci.draw_rect(Rect2(-18, -52, 36, 2), MADEIRA.lightened(0.15))


static func _bancada(ci: CanvasItem, t: float) -> void:
	elipse(ci, Vector2(2, 0), 30, 4.0, SOMBRA)
	caixa(ci, Rect2(-24, -14, 3, 14), MADEIRA_ESCURA)
	caixa(ci, Rect2(21, -14, 3, 14), MADEIRA_ESCURA)
	caixa(ci, Rect2(-22, -14, 44, 6), MADEIRA)
	ci.draw_rect(Rect2(-4, -12, 8, 1), Color("8a6a40"))
	caixa(ci, Rect2(-26, -19, 52, 5), MADEIRA.lightened(0.12))
	# erlenmeyer verde
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-17, -27), Vector2(-15, -27), Vector2(-12, -19), Vector2(-20, -19)]), Color(0.8, 0.9, 0.9, 0.35))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-18.5, -22), Vector2(-13.5, -22), Vector2(-12, -19), Vector2(-20, -19)]), Color("7fd13b"))
	var b := fmod(t * 6.0, 6.0)
	elipse(ci, Vector2(-16, -22 - b), 0.7, 0.7, Color(0.8, 1, 0.6, 1.0 - b / 6.0))
	# béquer laranja
	ci.draw_rect(Rect2(-6, -26, 7, 7), Color(0.8, 0.9, 0.9, 0.35))
	ci.draw_rect(Rect2(-6, -23, 7, 4), Color("e07a2a"))
	# tubos de ensaio
	caixa(ci, Rect2(5, -22, 14, 3), MADEIRA_ESCURA)
	var cores := [Color("d13b5a"), Color("3bb0d1"), Color("d1c03b")]
	for i in 3:
		ci.draw_rect(Rect2(7 + i * 4, -29, 2, 8), Color(0.8, 0.9, 0.9, 0.35))
		ci.draw_rect(Rect2(7 + i * 4, -25, 2, 4), cores[i])


static func _armario(ci: CanvasItem) -> void:
	elipse(ci, Vector2(2, 0), 17, 4.0, SOMBRA)
	caixa(ci, Rect2(-13, -46, 26, 46), MADEIRA)
	ci.draw_rect(Rect2(-11, -44, 10, 30), MADEIRA_ESCURA)
	ci.draw_rect(Rect2(1, -44, 10, 30), MADEIRA_ESCURA)
	ci.draw_rect(Rect2(-10, -43, 8, 28), Color(0.6, 0.7, 0.7, 0.15))
	ci.draw_rect(Rect2(2, -43, 8, 28), Color(0.6, 0.7, 0.7, 0.15))
	ci.draw_rect(Rect2(-8, -26, 3, 6), Color("7a5a2a"))
	ci.draw_rect(Rect2(4, -38, 4, 5), Color("3a5a3a"))
	ci.draw_rect(Rect2(-11, -12, 22, 9), MADEIRA_ESCURA)
	ci.draw_rect(Rect2(-2, -9, 4, 1), DOURADO)
	ci.draw_rect(Rect2(-2, -30, 1, 3), DOURADO)
	ci.draw_rect(Rect2(1, -30, 1, 3), DOURADO)
	ci.draw_rect(Rect2(-14, -48, 28, 3), MADEIRA.lightened(0.15))
	# frasco em cima
	ci.draw_rect(Rect2(-6, -55, 5, 7), Color(0.8, 0.9, 0.9, 0.35))
	ci.draw_rect(Rect2(-6, -52, 5, 4), Color("8a3bd1"))


static func _caixas(ci: CanvasItem) -> void:
	elipse(ci, Vector2(2, 0), 19, 4.0, SOMBRA)
	var papelao := Color("7a5a35")
	caixa(ci, Rect2(-14, -13, 16, 13), papelao)
	caixa(ci, Rect2(3, -10, 12, 10), papelao.darkened(0.1))
	caixa(ci, Rect2(-10, -24, 14, 11), papelao.lightened(0.05))
	ci.draw_rect(Rect2(-7, -13, 2, 13), Color("a08a60"))
	ci.draw_rect(Rect2(-4, -24, 2, 11), Color("a08a60"))
	ci.draw_rect(Rect2(5, -7, 6, 3), Color(0, 0, 0, 0.3))


static func _mesa_vela(ci: CanvasItem, t: float) -> void:
	elipse(ci, Vector2(2, 0), 14, 4.0, SOMBRA)
	caixa(ci, Rect2(-8, -12, 2, 12), MADEIRA_ESCURA)
	caixa(ci, Rect2(6, -12, 2, 12), MADEIRA_ESCURA)
	caixa(ci, Rect2(-11, -15, 22, 4), MADEIRA)
	var velas := [Vector2(-5, -15), Vector2(0, -15), Vector2(5, -15)]
	var alturas := [6.0, 9.0, 5.0]
	for i in 3:
		var base: Vector2 = velas[i]
		var alt: float = alturas[i]
		ci.draw_rect(Rect2(base.x - 1.5, base.y - alt, 3, alt), Color("e8dcc0"))
		ci.draw_rect(Rect2(base.x - 1.5, base.y - alt + 2, 1, 3), Color("fff4dc"))
		_chama(ci, base - Vector2(0, alt), t, i * 2.1)


static func _lampiao(ci: CanvasItem, t: float) -> void:
	elipse(ci, Vector2(2, 0), 9, 3.5, SOMBRA)
	caixa(ci, Rect2(-5, -4, 10, 4), Color("3a3028"))
	ci.draw_rect(Rect2(-4, -16, 8, 12), Color(1.0, 0.75, 0.4, 0.35))
	ci.draw_rect(Rect2(-5, -16, 1, 12), Color("3a3028"))
	ci.draw_rect(Rect2(4, -16, 1, 12), Color("3a3028"))
	_chama(ci, Vector2(0, -7), t, 0.0)
	caixa(ci, Rect2(-5, -19, 10, 3), Color("3a3028"))
	ci.draw_arc(Vector2(0, -21), 3, PI, TAU, 8, Color("3a3028"), 1.0)


static func _cabos(ci: CanvasItem) -> void:
	ci.draw_polyline(PackedVector2Array([Vector2(-30, 2), Vector2(-18, -2), Vector2(-6, 3), Vector2(8, -1), Vector2(22, 4), Vector2(34, 0)]), Color("141010"), 2.0)
	ci.draw_polyline(PackedVector2Array([Vector2(-26, 8), Vector2(-12, 5), Vector2(0, 9), Vector2(14, 6), Vector2(26, 10)]), Color("5a1a14"), 1.5)
	caixa(ci, Rect2(32, -2, 5, 4), Color("2a2a2a"))


static func _barril(ci: CanvasItem, t: float) -> void:
	var gosma := 0.5 + 0.15 * sin(t * 2.0)
	elipse(ci, Vector2(4, 1), 14, 3.5, Color(0.6, 0.8, 0.2, gosma))
	elipse(ci, Vector2(2, 0), 13, 4.0, SOMBRA)
	caixa(ci, Rect2(-9, -24, 18, 24), Color("4a5228"))
	ci.draw_rect(Rect2(-9, -20, 18, 2), Color("2e3418"))
	ci.draw_rect(Rect2(-9, -6, 18, 2), Color("2e3418"))
	ci.draw_rect(Rect2(-7, -23, 3, 21), Color(1, 1, 1, 0.08))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(0, -17), Vector2(5, -12), Vector2(0, -7), Vector2(-5, -12)]), Color("d1b02a"))
	ci.draw_rect(Rect2(-0.5, -15, 1, 4), CONTORNO)
	ci.draw_rect(Rect2(-0.5, -10, 1, 1), CONTORNO)


static func _sucata(ci: CanvasItem) -> void:
	elipse(ci, Vector2(2, 0), 24, 5.0, SOMBRA)
	caixa(ci, Rect2(-20, -10, 18, 10), Color("8a8270"))
	ci.draw_rect(Rect2(-18, -8, 14, 1), Color("4a4438"))
	ci.draw_rect(Rect2(-18, -5, 14, 1), Color("4a4438"))
	caixa(ci, Rect2(-6, -22, 20, 16), Color("b0a888"))
	ci.draw_rect(Rect2(-4, -20, 16, 11), Color("1e2420"))
	ci.draw_line(Vector2(-2, -18), Vector2(6, -12), Color(0.6, 0.7, 0.6, 0.4))
	caixa(ci, Rect2(8, -8, 12, 8), Color("2a2a2e"))
	ci.draw_rect(Rect2(10, -6, 3, 3), Color("4a6a4a"))
	ci.draw_polyline(PackedVector2Array([Vector2(14, -8), Vector2(18, -16), Vector2(22, -14)]), Color("141010"), 1.0)


static func _quadro(ci: CanvasItem) -> void:
	caixa(ci, Rect2(-24, -32, 48, 28), MADEIRA)
	ci.draw_rect(Rect2(-22, -30, 44, 24), Color("1e2e24"))
	var giz := Color(0.85, 0.85, 0.8, 0.7)
	var fonte := ThemeDB.fallback_font
	ci.draw_string(fonte, Vector2(-20, -21), "H2O", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, giz)
	ci.draw_string(fonte, Vector2(-2, -21), "NaCl", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, giz)
	ci.draw_string(fonte, Vector2(-20, -11), "Li+ e-", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, giz)
	ci.draw_line(Vector2(4, -13), Vector2(18, -13), giz)
	ci.draw_line(Vector2(15, -15), Vector2(18, -13), giz)
	ci.draw_rect(Rect2(-22, -6, 44, 2), MADEIRA_ESCURA)


static func _janela(ci: CanvasItem) -> void:
	caixa(ci, Rect2(-16, -42, 32, 38), MADEIRA)
	ci.draw_rect(Rect2(-14, -40, 28, 34), Color("141c28"))
	elipse(ci, Vector2(6, -32), 4, 4, Color("d8d8c0"))
	elipse(ci, Vector2(8, -33), 3, 3, Color("141c28"))
	ci.draw_rect(Rect2(-1, -40, 2, 34), MADEIRA)
	ci.draw_rect(Rect2(-14, -24, 28, 2), MADEIRA)
	ci.draw_line(Vector2(-12, -38), Vector2(-4, -28), Color(1, 1, 1, 0.12))
	ci.draw_rect(Rect2(-18, -5, 36, 3), MADEIRA.lightened(0.12))


static func _tabela(ci: CanvasItem) -> void:
	caixa(ci, Rect2(-24, -34, 48, 28), Color("c8b890"))
	var cores := [Color("c86a5a"), Color("d8a85a"), Color("7aa86a"), Color("6a8ac8"), Color("a87ac8")]
	for col in 18:
		for lin in 6:
			if lin == 0 and col > 0 and col < 17:
				continue
			if lin < 3 and col > 1 and col < 12:
				continue
			ci.draw_rect(Rect2(-22 + col * 2.4, -31 + lin * 3.5, 2, 3), cores[(col + lin) % cores.size()])
	ci.draw_rect(Rect2(-17, -10, 26, 1), Color("6a5a3a"))
