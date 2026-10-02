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


func _ready() -> void:
	set_process(alta)


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
	var madeira := Desenhos.MADEIRA

	if face_sul:
		_face(d, c, h, papel)
	if face_leste:
		_face(c, b, h, papel.darkened(0.25))
	var topo := Color("2a1a10") if alta else madeira.lightened(0.1)
	draw_colored_polygon(PackedVector2Array([a + h, b + h, c + h, d + h]), topo)
	draw_polyline(PackedVector2Array([d + h, c + h, b + h]), madeira.lightened(0.2), 1.0)


## Desenha uma face vertical entre os pontos p1 e p2 (na base).
func _face(p1: Vector2, p2: Vector2, h: Vector2, cor: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p1, p2, p2 + h, p1 + h]), cor)
	if not alta:
		draw_colored_polygon(PackedVector2Array([p1, p2, p2 + h, p1 + h]), Desenhos.MADEIRA.darkened(0.1))
		return
	# listras do papel de parede
	for t in [0.25, 0.5, 0.75]:
		var p := p1.lerp(p2, t)
		draw_line(p + Vector2(0, -8), p + h + Vector2(0, 6), cor.lightened(0.07), 2.0)
	# rodapé de madeira e moldura em cima
	var rodape := Vector2(0, -6)
	draw_colored_polygon(PackedVector2Array([p1, p2, p2 + rodape, p1 + rodape]), Desenhos.MADEIRA)
	draw_line(p1 + rodape, p2 + rodape, Desenhos.MADEIRA.lightened(0.2))
	var moldura := Vector2(0, 4)
	draw_colored_polygon(PackedVector2Array([p1 + h, p2 + h, p2 + h + moldura, p1 + h + moldura]), cor.darkened(0.35))
