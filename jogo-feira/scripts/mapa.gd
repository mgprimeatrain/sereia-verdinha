class_name Mapa
extends Node2D
## O mapa inteiro, contínuo: todas as salas ligadas por passagens.
## A lógica (colisão, posições) é feita numa grade "reta" e o desenho
## é inclinado na diagonal, como nos jogos com visão 3/4.

const CELULA := 16.0

var largura := 0
var altura := 0
var chao := {}  # Vector2i -> id da sala ("" nas passagens)
var bloqueado := {}  # Vector2i -> true (móveis e objetos)
var paredes := {}  # Vector2i -> Parede
var objetos: Array[Inspecionavel] = []
var por_sala := []  # [nó, sala]: tudo que só aparece quando o coelho está naquela sala
var escuridao: Escuridao
var piso: Node2D


## Converte uma posição da grade reta para a tela (visão inclinada).
static func iso(p: Vector2) -> Vector2:
	return Vector2(p.x - p.y, (p.x + p.y) * 0.5)


static func centro(celula: Vector2i) -> Vector2:
	return (Vector2(celula) + Vector2(0.5, 0.5)) * CELULA


func montar() -> void:
	largura = Dados.TAMANHO_MAPA.x
	altura = Dados.TAMANHO_MAPA.y
	y_sort_enabled = true

	for id in Dados.SALAS:
		var area: Rect2i = Dados.SALAS[id]["area"]
		for x in range(area.position.x, area.end.x):
			for y in range(area.position.y, area.end.y):
				chao[Vector2i(x, y)] = id
	for passagem in Dados.PASSAGENS:
		for x in range(passagem.position.x, passagem.end.x):
			for y in range(passagem.position.y, passagem.end.y):
				chao[Vector2i(x, y)] = ""

	piso = Node2D.new()
	piso.z_index = -10
	piso.draw.connect(_desenhar_piso)
	add_child(piso)

	escuridao = Escuridao.new()
	escuridao.configurar(Rect2(-altura * CELULA - 200, -200, (largura + altura) * CELULA + 400, (largura + altura) * CELULA * 0.5 + 400))
	add_child(escuridao)

	_criar_paredes()
	for item in Dados.MOVEIS:
		_criar_movel(item[0], item[1])
	for item in Dados.OBJETOS:
		var objeto := Inspecionavel.new()
		objeto.configurar(item[0])
		objeto.logico = centro(item[1])
		objeto.position = iso(objeto.logico)
		objeto.sala = chao[item[1]]
		add_child(objeto)
		objetos.append(objeto)
		por_sala.append([objeto, objeto.sala])
		bloqueado[item[1]] = true
		escuridao.adicionar_luz(objeto.position + Vector2(0, -16), 45, 0.4)


## Mostra só as paredes, móveis e objetos da sala atual.
func mostrar_sala(id: String) -> void:
	for item in por_sala:
		item[0].visible = item[1] == id


func eh_chao(c: Vector2i) -> bool:
	return chao.has(c)


## true se o coelho (uma caixinha em volta de p) cabe nesse lugar.
func livre(p: Vector2) -> bool:
	for canto in [Vector2(-4, -4), Vector2(4, -4), Vector2(-4, 4), Vector2(4, 4)]:
		var c := Vector2i((p + canto) / CELULA)
		if not chao.has(c) or bloqueado.has(c):
			return false
	return true


func sala_em(p: Vector2) -> String:
	return chao.get(Vector2i(p / CELULA), "")


func _sala_vizinha(c: Vector2i) -> String:
	for d in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		var id: String = chao.get(c + d, "x")
		if id != "x" and id != "":
			return id
	return "laboratorio"


func _criar_paredes() -> void:
	for x in range(-1, largura + 1):
		for y in range(-1, altura + 1):
			var c := Vector2i(x, y)
			if chao.has(c):
				continue
			var perto_do_chao := false
			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if chao.has(c + Vector2i(dx, dy)):
						perto_do_chao = true
			if not perto_do_chao:
				continue
			var parede := Parede.new()
			# paredes "da frente" (com chão atrás delas) ficam baixas para não tampar a visão
			parede.alta = not (chao.has(c + Vector2i(0, -1)) or chao.has(c + Vector2i(-1, 0)) or chao.has(c + Vector2i(-1, -1)))
			parede.face_sul = not _eh_parede(c + Vector2i(0, 1))
			parede.face_leste = not _eh_parede(c + Vector2i(1, 0))
			# a parede pertence à sala para onde ela está virada
			var lado := [Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)] if parede.alta else [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(-1, -1)]
			var dona := ""
			for d in lado:
				var id: String = chao.get(c + d, "")
				if id != "":
					dona = id
					break
			if dona == "":
				dona = _sala_vizinha(c)
			parede.papel = Dados.SALAS[dona]["papel"]
			por_sala.append([parede, dona])
			parede.position = iso(centro(c))
			add_child(parede)
			paredes[c] = parede


func _eh_parede(c: Vector2i) -> bool:
	if chao.has(c):
		return false
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if chao.has(c + Vector2i(dx, dy)):
				return true
	return false


func _criar_movel(tipo: String, celula: Vector2i) -> void:
	var movel := Movel.new()
	movel.tipo = tipo
	if paredes.has(celula):
		# quadro, janela e tabela ficam pendurados na face da parede
		var parede: Parede = paredes[celula]
		if chao.has(celula + Vector2i(0, 1)):
			movel.transform = Transform2D(Vector2(1, 0.5), Vector2(0, 1), Vector2(-8, 0))
		else:
			movel.transform = Transform2D(Vector2(1, -0.5), Vector2(0, 1), Vector2(8, 0))
		parede.add_child(movel)
		return

	movel.position = iso(centro(celula))
	por_sala.append([movel, chao.get(celula, _sala_vizinha(celula))])
	if tipo == "cabos":
		movel.z_index = -6
	else:
		bloqueado[celula] = true
	add_child(movel)

	var luz := Desenhos.luz_movel(tipo)
	if luz != Vector3.ZERO:
		escuridao.adicionar_luz(movel.position + Vector2(0, luz.x), luz.y, luz.z)
		var brilho := Escuridao.brilho(Color(1.0, 0.8, 0.6), luz.y * 0.5, 0.08)
		brilho.position = Vector2(0, luz.x)
		movel.add_child(brilho)


# ------------------------------------------------------------------ desenho do chão

func _desenhar_piso() -> void:
	for c: Vector2i in chao:
		var id: String = chao[c]
		var madeira: Color = Dados.SALAS[id if id != "" else "laboratorio"]["madeira"]
		var x0 := c.x * CELULA
		var y0 := c.y * CELULA
		# 4 tábuas por célula, que continuam pelas células vizinhas
		for i in 4:
			var ty := y0 + i * 4.0
			var linha := c.y * 4 + i
			var tabua := int((c.x * CELULA + (linha * 37) % 48) / 48.0)
			var tom := madeira.lightened(_ruido(linha, tabua) * 0.22 - 0.08)
			if id == "":
				tom = tom.darkened(0.15)
			_quad(Vector2(x0, ty), Vector2(x0 + CELULA, ty), Vector2(x0 + CELULA, ty + 4), Vector2(x0, ty + 4), tom)
			piso.draw_line(iso(Vector2(x0, ty + 4)), iso(Vector2(x0 + CELULA, ty + 4)), madeira.darkened(0.35))
			var emenda := fmod(c.x * CELULA + (linha * 37) % 48, 48.0)
			if emenda < CELULA:
				var ex := x0 + CELULA - emenda
				piso.draw_line(iso(Vector2(ex, ty)), iso(Vector2(ex, ty + 4)), madeira.darkened(0.35))

	# sombra das paredes altas no chão
	for c: Vector2i in chao:
		var x0 := c.x * CELULA
		var y0 := c.y * CELULA
		var parede_n: Parede = paredes.get(c + Vector2i(0, -1))
		var parede_o: Parede = paredes.get(c + Vector2i(-1, 0))
		var sombra := Color(Desenhos.SOMBRA, 0.25)
		if parede_n and parede_n.alta:
			_quad(Vector2(x0, y0), Vector2(x0 + CELULA, y0), Vector2(x0 + CELULA, y0 + 7), Vector2(x0, y0 + 7), sombra)
		if parede_o and parede_o.alta:
			_quad(Vector2(x0, y0), Vector2(x0 + 7, y0), Vector2(x0 + 7, y0 + CELULA), Vector2(x0, y0 + CELULA), sombra)

	# tapetes no meio das salas
	for id in Dados.SALAS:
		var tapete: Color = Dados.SALAS[id]["tapete"]
		if tapete.a == 0:
			continue
		var area: Rect2i = Dados.SALAS[id]["area"]
		var r := Rect2(Vector2(area.position) * CELULA, Vector2(area.size) * CELULA).grow(-CELULA * 2.5)
		_quad(r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y), tapete)
		_contorno(r, Desenhos.CONTORNO)
		_contorno(r.grow(-4), tapete.lightened(0.3))


func _ruido(a: int, b: int) -> float:
	return fmod(absf(sin(a * 12.9898 + b * 78.233) * 43758.5453), 1.0)


func _quad(a: Vector2, b: Vector2, c: Vector2, d: Vector2, cor: Color) -> void:
	piso.draw_colored_polygon(PackedVector2Array([iso(a), iso(b), iso(c), iso(d)]), cor)


func _contorno(r: Rect2, cor: Color) -> void:
	var pts := PackedVector2Array([
		iso(r.position), iso(Vector2(r.end.x, r.position.y)), iso(r.end),
		iso(Vector2(r.position.x, r.end.y)), iso(r.position)])
	piso.draw_polyline(pts, cor, 1.0)
