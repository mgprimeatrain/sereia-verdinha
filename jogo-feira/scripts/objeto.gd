class_name Inspecionavel
extends Node2D
## Um componente em cima de um pedestal. Quando o coelho chega perto,
## aparece a tecla E e dá para abrir a janela de inspeção.

var id := ""
var info: Dictionary
var cor := Color.WHITE
var textura: Texture2D
var logico := Vector2.ZERO  # posição na grade reta do mapa
var destacado := false
var visto := false
var tempo := 0.0
var marcador: Node2D
var sala := ""


func configurar(id_objeto: String) -> void:
	id = id_objeto
	info = Dados.COMPONENTES[id]
	cor = info["cor"]
	tempo = randf() * 10.0
	var caminho := "res://arte/componentes/%s.png" % id
	if ResourceLoader.exists(caminho):
		textura = load(caminho)

	# a tecla E e o "!" ficam por cima da escuridão
	marcador = Node2D.new()
	marcador.z_index = 70
	marcador.draw.connect(_desenhar_marcador)
	add_child(marcador)

	# brilho colorido em volta do objeto
	var luz := Escuridao.brilho(cor, 36, 0.25)
	luz.position = Vector2(0, -20)
	add_child(luz)


func _process(delta: float) -> void:
	tempo += delta
	queue_redraw()
	marcador.queue_redraw()


func _draw() -> void:
	Desenhos.elipse(self, Vector2(2, 0), 14, 4.5, Desenhos.SOMBRA)
	# pedestal de madeira
	Desenhos.caixa(self, Rect2(-9, -9, 18, 9), Desenhos.MADEIRA_ESCURA)
	draw_rect(Rect2(-7, -7, 14, 1), Desenhos.MADEIRA)
	Desenhos.caixa(self, Rect2(-11, -12, 22, 3), Desenhos.MADEIRA.lightened(0.15))

	var y := -27.0 + sin(tempo * 2.0) * 1.5
	if destacado:
		Desenhos.elipse(self, Vector2(0, y), 18, 18, Color(cor, 0.18 + 0.06 * sin(tempo * 6.0)))

	draw_set_transform(Vector2(0, y))
	if textura:
		var lado := 30.0 / maxf(textura.get_width(), textura.get_height())
		var tam := textura.get_size() * lado
		draw_texture_rect(textura, Rect2(-tam / 2.0, tam), false)
	else:
		Desenhos.desenhar(self, info["forma"], cor, tempo)
	draw_set_transform(Vector2.ZERO)



func _desenhar_marcador() -> void:
	var y := -27.0 + sin(tempo * 2.0) * 1.5
	var fonte := ThemeDB.fallback_font
	if destacado:
		var ky := y - 28.0 + sin(tempo * 5.0)
		Desenhos.caixa(marcador, Rect2(-5, ky - 5, 10, 10), Color("f0e6d0"))
		marcador.draw_string(fonte, Vector2(-5, ky + 3), "E", HORIZONTAL_ALIGNMENT_CENTER, 10, 9, Color("1a1620"))
	elif not visto:
		var ey := y - 22.0 + absf(sin(tempo * 4.0)) * -3.0
		marcador.draw_string_outline(fonte, Vector2(-5, ey), "!", HORIZONTAL_ALIGNMENT_CENTER, 10, 12, 3, Color("1a1620"))
		marcador.draw_string(fonte, Vector2(-5, ey), "!", HORIZONTAL_ALIGNMENT_CENTER, 10, 12, Color("ffc040"))
