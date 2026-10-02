class_name Jogador
extends Node2D
## O Coelho Cientista: anda com WASD/setas, corre com Shift, pula com Espaço
## e carrega a câmera.
##
## Animações: coloque as folhas de sprite (PNG com fundo transparente, todos os
## quadros do mesmo tamanho, em grade) na pasta arte/ com estes nomes.
## Se "colunas" e "linhas" não baterem com a sua imagem, é só mudar aqui.
## Sem as imagens, o jogo usa o coelho desenhado por código.

const VELOCIDADE := 75.0
const VELOCIDADE_CORRENDO := 130.0
const ALTURA_NA_TELA := 46.0  # altura do coelho em pixels do jogo
const ANIMACOES := {
	"andando": {"arquivo": "res://arte/coelho_andando.png", "colunas": 8, "linhas": 3, "fps": 24},
	"correndo": {"arquivo": "res://arte/coelho_correndo.png", "colunas": 7, "linhas": 3, "fps": 24},
	"pulando": {"arquivo": "res://arte/coelho_pulando.png", "colunas": 12, "linhas": 2, "fps": 24},
}

var mapa: Mapa
var logico := Vector2.ZERO  # posição na grade reta do mapa
var direcao := Vector2.DOWN  # direção na tela
var andando := false
var passo := 0.0
var correndo := false
var pulo := 0.0  # tempo desde o começo do pulo (< 0 = no chão)
var camera: Camera2D
var sprite: AnimatedSprite2D


func _ready() -> void:
	# Câmera estilo Enigma do Medo: segue solta, com atraso,
	# e olha um pouco para onde o coelho está andando.
	camera = Camera2D.new()
	camera.position = Vector2(0, -14)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 3.5
	add_child(camera)

	var brilho := Escuridao.brilho(Color(1.0, 0.65, 0.35), 70, 0.12)
	brilho.position = Vector2(0, -14)
	add_child(brilho)

	pulo = -1.0
	_carregar_animacoes()


func _carregar_animacoes() -> void:
	var quadros := SpriteFrames.new()
	quadros.remove_animation("default")
	var altura_quadro := 0.0
	for nome in ANIMACOES:
		var info: Dictionary = ANIMACOES[nome]
		if not ResourceLoader.exists(info["arquivo"]):
			continue
		var folha: Texture2D = load(info["arquivo"])
		var tam := Vector2(folha.get_width() / info["colunas"], folha.get_height() / info["linhas"])
		altura_quadro = tam.y
		quadros.add_animation(nome)
		quadros.set_animation_speed(nome, info["fps"])
		quadros.set_animation_loop(nome, nome != "pulando")
		for linha in info["linhas"]:
			for coluna in info["colunas"]:
				var quadro := AtlasTexture.new()
				quadro.atlas = folha
				quadro.region = Rect2(Vector2(coluna, linha) * tam, tam)
				quadros.add_frame(nome, quadro)
	if not quadros.has_animation("andando"):
		return
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = quadros
	sprite.scale = Vector2.ONE * (ALTURA_NA_TELA / altura_quadro)
	sprite.offset = Vector2(0, -altura_quadro / 2.0)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.animation = "andando"
	add_child(sprite)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pular") and pulo < 0.0:
		pulo = 0.0


func _physics_process(delta: float) -> void:
	var entrada := Input.get_vector("esquerda", "direita", "cima", "baixo")
	andando = entrada != Vector2.ZERO
	correndo = andando and Input.is_action_pressed("correr")
	if andando:
		direcao = entrada
		passo += delta * (16.0 if correndo else 11.0)
		# a tela é inclinada: converte a direção da tela para a grade do mapa
		var velocidade := VELOCIDADE_CORRENDO if correndo else VELOCIDADE
		var movimento := Vector2(entrada.y + entrada.x * 0.5, entrada.y - entrada.x * 0.5) * velocidade * delta
		var tentativa := logico + Vector2(movimento.x, 0)
		if mapa.livre(tentativa):
			logico = tentativa
		tentativa = logico + Vector2(0, movimento.y)
		if mapa.livre(tentativa):
			logico = tentativa
	else:
		passo = 0.0
	position = Mapa.iso(logico)

	var olhar := entrada * Vector2(28, 18)
	camera.offset = camera.offset.lerp(olhar, delta * 1.5)

	# pulo: um arco de 0,5 segundo
	var altura_pulo := 0.0
	if pulo >= 0.0:
		pulo += delta
		altura_pulo = sin(clampf(pulo / 0.5, 0.0, 1.0) * PI) * 14.0
		if pulo >= 0.5:
			pulo = -1.0

	if sprite:
		if absf(direcao.x) > 0.1:
			sprite.flip_h = direcao.x < 0
		sprite.position.y = -altura_pulo
		_animar()
	queue_redraw()


func _animar() -> void:
	var quadros := sprite.sprite_frames
	if pulo >= 0.0 and quadros.has_animation("pulando"):
		if sprite.animation != "pulando":
			sprite.play("pulando")
		return
	var nome := "correndo" if correndo and quadros.has_animation("correndo") else "andando"
	if andando:
		if sprite.animation != nome or not sprite.is_playing():
			sprite.play(nome)
	else:
		# parado: primeiro quadro da caminhada
		sprite.animation = "andando"
		sprite.stop()
		sprite.frame = 0


func posicionar(p: Vector2) -> void:
	logico = p
	position = Mapa.iso(logico)
	camera.reset_smoothing()


func _draw() -> void:
	if sprite:
		Desenhos.elipse(self, Vector2.ZERO, 8, 2.5, Color(0, 0, 0, 0.35))
	else:
		draw_set_transform(Vector2(0, -_altura_pulo_atual()))
		Desenhos.coelho(self, direcao, passo, andando)
		draw_set_transform(Vector2.ZERO)
	if pulo >= 0.0:
		Desenhos.elipse(self, Vector2.ZERO, 7, 2, Color(0, 0, 0, 0.25))


func _altura_pulo_atual() -> float:
	return sin(clampf(pulo / 0.5, 0.0, 1.0) * PI) * 14.0 if pulo >= 0.0 else 0.0
