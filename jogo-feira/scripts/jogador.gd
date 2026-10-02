class_name Jogador
extends CharacterBody2D
## O Coelho Cientista: anda com WASD/setas e carrega a câmera.
## Se existir res://arte/coelho.png, a imagem é usada no lugar do desenho.

const VELOCIDADE := 90.0
const IMAGEM := "res://arte/coelho.png"

var direcao := Vector2.DOWN
var andando := false
var passo := 0.0
var tempo := 0.0
var camera: Camera2D
var sprite: Sprite2D


func _ready() -> void:
	var forma := CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = Vector2(10, 6)
	forma.shape = ret
	forma.position = Vector2(0, -3)
	add_child(forma)

	# Câmera estilo Enigma do Medo: segue com atraso e para nas bordas da sala.
	camera = Camera2D.new()
	camera.position = Vector2(0, -12)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 4.5
	add_child(camera)

	# brilho quente da lanterna em volta do coelho
	var brilho := Escuridao.brilho(Color(1.0, 0.6, 0.3), 70, 0.16)
	brilho.position = Vector2(0, -14)
	add_child(brilho)

	if ResourceLoader.exists(IMAGEM):
		sprite = Sprite2D.new()
		sprite.texture = load(IMAGEM)
		var altura := float(sprite.texture.get_height())
		sprite.scale = Vector2.ONE * minf(1.0, 36.0 / altura)
		sprite.offset = Vector2(0, -altura / 2.0)
		add_child(sprite)


func _physics_process(delta: float) -> void:
	tempo += delta
	var entrada := Input.get_vector("esquerda", "direita", "cima", "baixo")
	velocity = entrada * VELOCIDADE
	andando = entrada != Vector2.ZERO
	if andando:
		direcao = entrada
		passo += delta * 11.0
	else:
		passo = 0.0
	move_and_slide()

	if sprite:
		if absf(direcao.x) > 0.1:
			sprite.flip_h = direcao.x < 0
		sprite.position.y = -absf(sin(passo)) * 1.5
	queue_redraw()


func ajustar_camera(tamanho: Vector2) -> void:
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(tamanho.x)
	camera.limit_bottom = int(tamanho.y)
	camera.make_current()
	camera.reset_smoothing()


func _draw() -> void:
	if sprite:
		Desenhos.elipse(self, Vector2.ZERO, 8, 2.5, Color(0, 0, 0, 0.35))
	else:
		Desenhos.coelho(self, direcao, passo, andando)
