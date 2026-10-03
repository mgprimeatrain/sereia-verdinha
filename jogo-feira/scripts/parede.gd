class_name Parede
extends Node2D
## Um bloco de parede na visão inclinada. As paredes do fundo são altas;
## as da frente são baixinhas. Se o coelho passar atrás de uma parede alta,
## ela fica transparente.

const ALTURA := 44.0
const BAIXA := 7.0

static var alvo: Node2D

var alta := true
var face_sul := true
var face_leste := true
var papel := Color("3a2a1e")
var antiga := false  # museu: papel de parede e rodapé de madeira; senão, parede lisa moderna
var salas_fundo := {}  # salas para as quais esta é uma parede do fundo (alta)
var salas_frente := {}  # salas para as quais esta é uma parede da frente (baixa)


## Ajusta a parede para a sala onde o coelho está: some se não for dessa sala,
## e fica alta ou baixa conforme o lado da sala em que ela está.
func usar_sala(id: String) -> void:
	visible = salas_fundo.has(id) or salas_frente.has(id)
	if not visible:
		return
	alta = not salas_frente.has(id)
	papel = Dados.SALAS[id]["papel"]
	antiga = Dados.SALAS[id].get("antigo", false)
	set_process(alta)
	if not alta:
		modulate.a = 1.0
	queue_redraw()


func _process(delta: float) -> void:
	var transparente := false
	if alvo:
		var p := alvo.position
		transparente = p.y < position.y and p.y > position.y - ALTURA - 20 and absf(p.x - position.x) < 22
	modulate.a = move_toward(modulate.a, 0.35 if transparente else 1.0, delta * 4.0)


func _draw() -> void:
	# cantos da célula na tela, em volta do centro
	var a := Vector2(0, -8)
	var b := Vector2(16, 0)
	var c := Vector2(0, 8)
	var d := Vector2(-16, 0)
	var h := Vector2(0, -(ALTURA if alta else BAIXA))
	var contorno := Desenhos.CONTORNO

	if face_sul:
		_face(d, c, h, papel)
	if face_leste:
		_face(c, b, h, papel.darkened(0.12))
	var topo := papel.darkened(0.35) if alta else (Desenhos.MADEIRA if antiga else Desenhos.METAL)
	draw_colored_polygon(PackedVector2Array([a + h, b + h, c + h, d + h]), topo)
	# contorno preto grosso, como o do coelho
	if face_sul:
		draw_line(d + h, c + h, contorno, 1.0)
		draw_line(d, c, contorno, 1.0)
	if face_leste:
		draw_line(c + h, b + h, contorno, 1.0)
		draw_line(c, b, contorno, 1.0)
	if face_sul and face_leste:
		draw_line(c, c + h, contorno, 1.0)


## Desenha uma face vertical entre os pontos p1 e p2 (na base).
func _face(p1: Vector2, p2: Vector2, h: Vector2, cor: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p1, p2, p2 + h, p1 + h]), cor)
	if not alta:
		draw_colored_polygon(PackedVector2Array([p1, p2, p2 + h, p1 + h]), Desenhos.MADEIRA_ESCURA if antiga else Desenhos.METAL_ESCURO)
		return
	if not antiga:
		# parede moderna: lisa, rodapé cinza e uma faixa colorida
		var rodape_m := Vector2(0, -5)
		draw_colored_polygon(PackedVector2Array([p1, p2, p2 + rodape_m, p1 + rodape_m]), Desenhos.METAL)
		draw_line(p1 + rodape_m, p2 + rodape_m, Desenhos.CONTORNO, 1.0)
		var faixa_m := Vector2(0, -20)
		draw_colored_polygon(PackedVector2Array([p1 + faixa_m, p2 + faixa_m, p2 + faixa_m + Vector2(0, -2), p1 + faixa_m + Vector2(0, -2)]), cor.darkened(0.15))
		return
	# bolinhas do papel de parede
	for t in [0.25, 0.75]:
		for alt in [16.0, 30.0]:
			var p := p1.lerp(p2, t) + Vector2(0, -alt)
			draw_rect(Rect2(p - Vector2(1, 1), Vector2(2, 2)), cor.darkened(0.12))
	# rodapé de madeira e faixa em cima
	var rodape := Vector2(0, -7)
	draw_colored_polygon(PackedVector2Array([p1, p2, p2 + rodape, p1 + rodape]), Desenhos.MADEIRA)
	draw_line(p1 + rodape, p2 + rodape, Desenhos.CONTORNO, 1.0)
	var faixa := Vector2(0, 5)
	draw_colored_polygon(PackedVector2Array([p1 + h, p2 + h, p2 + h + faixa, p1 + h + faixa]), cor.darkened(0.2))
