class_name Movel
extends Node2D
## Um móvel de decoração (estante, bancada, velas...). O ponto (0, 0) fica na base.
## Quadros, janelas e tabelas ficam dentro de uma Parede, inclinados junto com ela.

const ANIMADOS := ["mesa_vela", "lampiao", "bancada", "barril"]

var tipo := ""
var tempo := 0.0


func _ready() -> void:
	tempo = randf() * 10.0
	set_process(tipo in ANIMADOS)


func _process(delta: float) -> void:
	tempo += delta
	queue_redraw()


func _draw() -> void:
	Desenhos.movel(self, tipo, tempo)
