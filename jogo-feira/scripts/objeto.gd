class_name Inspecionavel
extends Area2D
## Um componente em cima de um pedestal. Quando o coelho chega perto,
## aparece a tecla E e dá para abrir a janela de inspeção.

var id := ""
var info: Dictionary
var cor := Color.WHITE
var textura: Texture2D
var perto := false
var destacado := false
var visto := false
var tempo := 0.0


func configurar(id_objeto: String) -> void:
	id = id_objeto
	info = Dados.COMPONENTES[id]
	cor = info["cor"]
	tempo = randf() * 10.0
	var caminho := "res://arte/componentes/%s.png" % id
	if ResourceLoader.exists(caminho):
		textura = load(caminho)

	# área onde o coelho consegue inspecionar
	var alcance := CollisionShape2D.new()
	var circulo := CircleShape2D.new()
	circulo.radius = 28
	alcance.shape = circulo
	alcance.position = Vector2(0, -4)
	add_child(alcance)
	body_entered.connect(_corpo_entrou)
	body_exited.connect(_corpo_saiu)

	# pedestal sólido (o coelho não atravessa)
	var corpo := StaticBody2D.new()
	var forma := CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = Vector2(22, 8)
	forma.shape = ret
	forma.position = Vector2(0, -3)
	corpo.add_child(forma)
	add_child(corpo)

	# brilho colorido em volta do objeto
	var luz := Escuridao.brilho(cor, 40, 0.35)
	luz.position = Vector2(0, -20)
	add_child(luz)


func _corpo_entrou(corpo: Node2D) -> void:
	if corpo is Jogador:
		perto = true


func _corpo_saiu(corpo: Node2D) -> void:
	if corpo is Jogador:
		perto = false


func _process(delta: float) -> void:
	tempo += delta
	queue_redraw()


func _draw() -> void:
	Desenhos.elipse(self, Vector2(0, 0), 13, 3.5, Color(0, 0, 0, 0.35))
	Desenhos.caixa(self, Rect2(-10, -9, 20, 9), Color("2a2d38"))
	draw_rect(Rect2(-11, -11, 22, 3), Color("4a4f60"))

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

	var fonte := ThemeDB.fallback_font
	if destacado:
		var ky := y - 28.0 + sin(tempo * 5.0)
		Desenhos.caixa(self, Rect2(-5, ky - 5, 10, 10), Color("f0f0f0"))
		draw_string(fonte, Vector2(-5, ky + 3), "E", HORIZONTAL_ALIGNMENT_CENTER, 10, 9, Color("1a1620"))
	elif not visto:
		var ey := y - 22.0 + absf(sin(tempo * 4.0)) * -3.0
		draw_string_outline(fonte, Vector2(-5, ey), "!", HORIZONTAL_ALIGNMENT_CENTER, 10, 12, 3, Color("1a1620"))
		draw_string(fonte, Vector2(-5, ey), "!", HORIZONTAL_ALIGNMENT_CENTER, 10, 12, Color("ffd94a"))
