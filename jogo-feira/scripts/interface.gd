class_name Interface
extends CanvasLayer
## Tudo que fica por cima do jogo: tela de título, HUD, janela de inspeção e fade.

const LARGURA := 480.0
const ALTURA := 270.0

const SHADER_VINHETA := """
shader_type canvas_item;
uniform float forca = 0.3;
float ruido(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	vec2 uv = UV - vec2(0.5);
	uv.x *= 1.25;
	float v = smoothstep(0.28, 0.75, length(uv));
	float grao = ruido(floor(UV * vec2(480.0, 270.0)) + vec2(floor(TIME * 12.0) * 3.1)) * 0.02;
	COLOR = vec4(0.02, 0.01, 0.0, v * forca + grao);
}
"""

var titulo: Control
var texto_comecar: Label
var nome_sala: Label
var contador: Label
var cartao_sala: Label
var dica: Label
var aviso: Label
var fade_rect: ColorRect

var janela: PanelContainer
var estilo_janela: StyleBoxFlat
var moldura_estilo: StyleBoxFlat
var imagem: TextureRect
var desenho: TelaDesenho
var destaque: Label
var titulo_janela: Label
var selo_novo: Label
var texto: Label
var curiosidade: Label
var caixa_curiosidade: PanelContainer
var estilo_curiosidade: StyleBoxFlat

var _tween_cartao: Tween
var _tween_aviso: Tween
var tempo := 0.0


func _ready() -> void:
	layer = 10
	_criar_vinheta()
	_criar_hud()
	_criar_janela()
	_criar_titulo()
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fade_rect)


func _process(delta: float) -> void:
	tempo += delta
	if titulo.visible:
		texto_comecar.modulate.a = 0.55 + 0.45 * sin(tempo * 4.0)


# ------------------------------------------------------------------ montagem

func _label(conteudo: String, tamanho: int, cor := Color.WHITE, contorno := 3) -> Label:
	var l := Label.new()
	l.text = conteudo
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	if contorno > 0:
		l.add_theme_constant_override("outline_size", contorno)
		l.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.06, 0.95))
	return l


## Label que ocupa a largura toda, centralizada, na altura y.
func _linha(conteudo: String, tamanho: int, cor: Color, y: float, pai: Node) -> Label:
	var l := _label(conteudo, tamanho, cor)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.anchor_right = 1.0
	l.offset_top = y
	pai.add_child(l)
	return l


func _criar_vinheta() -> void:
	var v := ColorRect.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shader := Shader.new()
	shader.code = SHADER_VINHETA
	var mat := ShaderMaterial.new()
	mat.shader = shader
	v.material = mat
	add_child(v)


func _criar_hud() -> void:
	nome_sala = _label("", 8, Color("e8dcc8"))
	nome_sala.position = Vector2(8, 5)
	add_child(nome_sala)

	contador = _label("", 8, Color("ffd94a"))
	contador.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	contador.anchor_left = 1.0
	contador.anchor_right = 1.0
	contador.offset_left = -200
	contador.offset_right = -8
	contador.offset_top = 5
	add_child(contador)

	cartao_sala = _linha("", 18, Color.WHITE, 60, self)
	cartao_sala.modulate.a = 0.0

	dica = _linha("", 8, Color.WHITE, ALTURA - 22, self)
	aviso = _linha("", 9, Color("ffd94a"), ALTURA - 48, self)
	aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	aviso.offset_left = 40
	aviso.offset_right = -40
	aviso.modulate.a = 0.0


func _criar_janela() -> void:
	janela = PanelContainer.new()
	estilo_janela = StyleBoxFlat.new()
	estilo_janela.bg_color = Color(0.07, 0.05, 0.04, 0.96)
	estilo_janela.set_border_width_all(2)
	estilo_janela.set_corner_radius_all(4)
	estilo_janela.set_content_margin_all(10)
	estilo_janela.shadow_color = Color(0, 0, 0, 0.5)
	estilo_janela.shadow_size = 6
	janela.add_theme_stylebox_override("panel", estilo_janela)
	janela.custom_minimum_size = Vector2(440, 0)
	janela.set_anchors_preset(Control.PRESET_CENTER)
	janela.grow_horizontal = Control.GROW_DIRECTION_BOTH
	janela.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(janela)

	var colunas := HBoxContainer.new()
	colunas.add_theme_constant_override("separation", 12)
	janela.add_child(colunas)

	# coluna da esquerda: o componente ampliado
	var esquerda := VBoxContainer.new()
	esquerda.add_theme_constant_override("separation", 4)
	colunas.add_child(esquerda)

	var moldura := PanelContainer.new()
	moldura.custom_minimum_size = Vector2(120, 120)
	moldura_estilo = StyleBoxFlat.new()
	moldura_estilo.bg_color = Color(0.12, 0.09, 0.07)
	moldura_estilo.set_border_width_all(1)
	moldura_estilo.set_corner_radius_all(3)
	moldura.add_theme_stylebox_override("panel", moldura_estilo)
	esquerda.add_child(moldura)

	imagem = TextureRect.new()
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagem.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	moldura.add_child(imagem)

	desenho = TelaDesenho.new()
	desenho.escala = 3.5
	moldura.add_child(desenho)

	destaque = _label("", 18, Color.WHITE)
	destaque.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	esquerda.add_child(destaque)
	var legenda := _label("química em destaque", 6, Color("9a8a78"), 0)
	legenda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	esquerda.add_child(legenda)

	# coluna da direita: textos
	var direita := VBoxContainer.new()
	direita.custom_minimum_size = Vector2(280, 0)
	direita.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	direita.add_theme_constant_override("separation", 6)
	colunas.add_child(direita)

	var cabecalho := HBoxContainer.new()
	direita.add_child(cabecalho)
	titulo_janela = _label("", 13, Color.WHITE)
	titulo_janela.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titulo_janela.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cabecalho.add_child(titulo_janela)
	selo_novo = _label("NOVO!", 9, Color("ffd94a"))
	cabecalho.add_child(selo_novo)

	texto = _label("", 8, Color("e8dcc8"), 0)
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	direita.add_child(texto)

	caixa_curiosidade = PanelContainer.new()
	estilo_curiosidade = StyleBoxFlat.new()
	estilo_curiosidade.border_width_left = 2
	estilo_curiosidade.set_content_margin_all(5)
	estilo_curiosidade.content_margin_left = 7
	caixa_curiosidade.add_theme_stylebox_override("panel", estilo_curiosidade)
	direita.add_child(caixa_curiosidade)
	curiosidade = _label("", 7, Color("ffe9a8"), 0)
	curiosidade.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caixa_curiosidade.add_child(curiosidade)

	var fechar := _label("[E] fechar", 6, Color("9a8a78"), 0)
	fechar.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	direita.add_child(fechar)

	janela.visible = false


func _criar_titulo() -> void:
	titulo = Control.new()
	titulo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(titulo)

	var fundo := ColorRect.new()
	fundo.color = Color("0c0806")
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	titulo.add_child(fundo)

	var luz := TelaDesenho.new()
	luz.forma = "coelho"
	luz.escala = 2.4
	luz.deslocamento = Vector2(0, 62)
	luz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	titulo.add_child(luz)

	_linha("COELHO CIENTISTA", 26, Color("f0c070"), 18, titulo)
	_linha("e a Química na Tecnologia", 11, Color("c8a888"), 54, titulo)
	texto_comecar = _linha("Aperte E para começar", 10, Color.WHITE, 206, titulo)
	_linha("WASD/setas: andar    Shift: correr    Espaço: pular    E: inspecionar    F11: tela cheia", 7, Color("9a8a78"), 230, titulo)
	_linha("Feira de Ciências", 6, Color("6a5a48"), 252, titulo)


# ------------------------------------------------------------------ ações

func esconder_titulo() -> void:
	var tw := create_tween()
	tw.tween_property(titulo, "modulate:a", 0.0, 0.5)
	tw.tween_callback(titulo.hide)


func atualizar_contador(achados: int, total: int) -> void:
	contador.text = "Componentes: %d / %d" % [achados, total]
	if achados == total:
		contador.add_theme_color_override("font_color", Color("7dff8a"))


func mostrar_sala(nome: String) -> void:
	nome_sala.text = nome
	cartao_sala.text = nome
	if _tween_cartao:
		_tween_cartao.kill()
	cartao_sala.modulate.a = 0.0
	_tween_cartao = create_tween()
	_tween_cartao.tween_property(cartao_sala, "modulate:a", 1.0, 0.4)
	_tween_cartao.tween_interval(1.4)
	_tween_cartao.tween_property(cartao_sala, "modulate:a", 0.0, 0.6)


func mostrar_dica(conteudo: String) -> void:
	dica.text = conteudo


func mostrar_aviso(conteudo: String, duracao := 3.0) -> void:
	aviso.text = conteudo
	if _tween_aviso:
		_tween_aviso.kill()
	_tween_aviso = create_tween()
	_tween_aviso.tween_property(aviso, "modulate:a", 1.0, 0.3)
	_tween_aviso.tween_interval(duracao)
	_tween_aviso.tween_property(aviso, "modulate:a", 0.0, 0.6)


func fade(escurecer: bool) -> Signal:
	var tw := create_tween()
	tw.tween_property(fade_rect, "color:a", 1.0 if escurecer else 0.0, 0.25)
	return tw.finished


func abrir_inspecao(info: Dictionary, textura: Texture2D, novo: bool, total: int) -> void:
	var cor: Color = info["cor"]
	estilo_janela.border_color = cor
	moldura_estilo.border_color = cor.darkened(0.3)
	estilo_curiosidade.bg_color = Color(cor, 0.12)
	estilo_curiosidade.border_color = cor

	imagem.texture = textura
	imagem.visible = textura != null
	desenho.visible = textura == null
	desenho.forma = info["forma"]
	desenho.cor = cor

	destaque.text = info["destaque"]
	destaque.add_theme_color_override("font_color", cor.lightened(0.3))
	titulo_janela.text = info["nome"]
	selo_novo.visible = novo
	texto.text = info["texto"]
	curiosidade.text = "Você sabia? " + str(info["curiosidade"]).replace("{total}", str(total))

	dica.text = ""
	janela.visible = true
	janela.modulate.a = 0.0
	create_tween().tween_property(janela, "modulate:a", 1.0, 0.15)


func fechar_inspecao() -> void:
	janela.visible = false
