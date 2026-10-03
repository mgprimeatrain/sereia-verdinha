class_name CaixaFala
extends PanelContainer
## Caixinha de diálogo do Coelho Cientista, com o rostinho dele e o texto
## aparecendo letra por letra. Se existir res://arte/coelho_rosto.png, usa a imagem.

const ROSTO := "res://arte/coelho_rosto.png"
const LETRAS_POR_SEGUNDO := 45.0

var texto: Label
var dica: Label
var _letras := 0.0


func _ready() -> void:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	estilo.border_color = Color("7fe0ff")
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(4)
	estilo.set_content_margin_all(8)
	add_theme_stylebox_override("panel", estilo)
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_left = 20
	offset_right = -20
	offset_top = -86
	offset_bottom = -10

	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 10)
	add_child(linha)

	var moldura := PanelContainer.new()
	moldura.custom_minimum_size = Vector2(58, 58)
	moldura.clip_contents = true
	var estilo_moldura := StyleBoxFlat.new()
	estilo_moldura.bg_color = Color("2a3a5a")
	estilo_moldura.border_color = Color("111015")
	estilo_moldura.set_border_width_all(2)
	estilo_moldura.set_corner_radius_all(3)
	moldura.add_theme_stylebox_override("panel", estilo_moldura)
	moldura.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	linha.add_child(moldura)
	if ResourceLoader.exists(ROSTO):
		var foto := TextureRect.new()
		foto.texture = load(ROSTO)
		foto.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		foto.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		foto.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		moldura.add_child(foto)
	else:
		var desenho := TelaDesenho.new()
		desenho.forma = "coelho"
		desenho.escala = 2.4
		desenho.deslocamento = Vector2(0, 50)
		moldura.add_child(desenho)

	var coluna := VBoxContainer.new()
	coluna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coluna.add_theme_constant_override("separation", 3)
	linha.add_child(coluna)
	var nome := _label("Coelho Cientista", 8, Color("7fe0ff"))
	coluna.add_child(nome)
	texto = _label("", 8, Color("f0f0f4"))
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coluna.add_child(texto)
	dica = _label("[E] continuar", 6, Color("9a9aa8"))
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	coluna.add_child(dica)
	visible = false


func _label(conteudo: String, tamanho: int, cor: Color) -> Label:
	var l := Label.new()
	l.text = conteudo
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	return l


func mostrar(conteudo: String) -> void:
	texto.text = conteudo
	texto.visible_characters = 0
	_letras = 0.0
	visible = true


func _process(delta: float) -> void:
	if not visible or texto.visible_characters < 0:
		return
	_letras += delta * LETRAS_POR_SEGUNDO
	texto.visible_characters = int(_letras)
	if texto.visible_characters >= texto.get_total_character_count():
		texto.visible_characters = -1
	dica.modulate.a = 1.0 if texto.visible_characters < 0 else 0.3


## Aperto do E: se o texto ainda está aparecendo, mostra tudo; senão fecha.
## Devolve true quando a caixa fechou.
func avancar() -> bool:
	if texto.visible_characters >= 0:
		texto.visible_characters = -1
		return false
	visible = false
	return true
