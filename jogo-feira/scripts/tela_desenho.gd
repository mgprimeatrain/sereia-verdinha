class_name TelaDesenho
extends Control
## Mostra um desenho de Desenhos ampliado dentro da interface.

var forma := ""
var cor := Color.WHITE
var escala := 4.0
var deslocamento := Vector2.ZERO
var tempo := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	tempo += delta
	queue_redraw()


func _draw() -> void:
	draw_set_transform(size / 2.0 + deslocamento, 0.0, Vector2(escala, escala))
	if forma == "coelho":
		Desenhos.coelho(self, Vector2.DOWN, tempo * 3.0, true)
	else:
		Desenhos.desenhar(self, forma, cor, tempo)
