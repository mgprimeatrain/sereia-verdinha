class_name Jogador
extends Node2D
## O Coelho Cientista: anda com WASD/setas, corre com Shift, pula com Espaço
## e carrega a câmera.
##
## Imagens do coelho (todas na pasta arte/, PNG com fundo transparente):
##   - DIRECOES: uma imagem parada para cada lado que o coelho olha.
##     A de lado deve estar virada para a DIREITA (o jogo espelha para a esquerda).
##   - ANIMACOES: folhas de sprite (quadros do mesmo tamanho, em grade) com o
##     coelho de lado. Se "colunas" e "linhas" não baterem com a imagem, mude aqui.
## O que não existir é trocado pelo que tiver; sem nenhuma imagem, o jogo usa
## o coelho desenhado por código.

const VELOCIDADE := 75.0
const VELOCIDADE_CORRENDO := 130.0
const ALTURA_NA_TELA := 46.0  # altura do coelho em pixels do jogo
const DIRECOES := {
	"frente": "res://arte/coelho_frente.png",
	"costas": "res://arte/coelho_costas.png",
	"lado": "res://arte/coelho_lado.png",
}
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
var sprite: AnimatedSprite2D  # animações de lado
var parado: Sprite2D  # imagens de frente, costas e lado
var texturas := {}


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
	_carregar_direcoes()


func _carregar_direcoes() -> void:
	for vista in DIRECOES:
		if ResourceLoader.exists(DIRECOES[vista]):
			texturas[vista] = load(DIRECOES[vista])
	if texturas.is_empty():
		return
	parado = Sprite2D.new()
	parado.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(parado)


func _usar_imagem(textura: Texture2D) -> void:
	parado.texture = textura
	var altura := float(textura.get_height())
	parado.scale = Vector2.ONE * (ALTURA_NA_TELA / altura)
	parado.offset = Vector2(0, -altura / 2.0)


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

	_animar(altura_pulo)
	queue_redraw()


## Para onde o coelho está olhando na tela: "frente", "costas" ou "lado".
func vista() -> String:
	if absf(direcao.x) >= absf(direcao.y):
		return "lado"
	return "costas" if direcao.y < 0 else "frente"


func _animar(altura_pulo: float) -> void:
	var olhando := vista()
	var espelhar := direcao.x < -0.1 if absf(direcao.x) > 0.1 else (sprite.flip_h if sprite else false)

	# de lado e se mexendo (ou pulando): usa as animações, se existirem
	var usar_animacao := sprite != null and olhando == "lado" and (andando or pulo >= 0.0 or not texturas.has("lado"))
	if sprite and not texturas.has("frente") and not texturas.has("costas"):
		usar_animacao = true  # só tem as animações: usa elas para tudo
	if usar_animacao:
		sprite.visible = true
		if parado:
			parado.visible = false
		sprite.flip_h = espelhar
		sprite.position.y = -altura_pulo
		var quadros := sprite.sprite_frames
		if pulo >= 0.0 and quadros.has_animation("pulando"):
			if sprite.animation != "pulando":
				sprite.play("pulando")
		elif andando:
			var nome := "correndo" if correndo and quadros.has_animation("correndo") else "andando"
			if sprite.animation != nome or not sprite.is_playing():
				sprite.play(nome)
		else:
			sprite.animation = "andando"
			sprite.stop()
			sprite.frame = 0
		return

	if sprite:
		sprite.visible = false
	if parado == null:
		return
	# imagem parada da direção (ou a que tiver), balançando ao andar
	var textura: Texture2D = texturas.get(olhando, texturas.get("frente", texturas.values()[0]))
	if parado.texture != textura:
		_usar_imagem(textura)
	parado.visible = true
	parado.flip_h = espelhar and olhando == "lado"
	var balanco := absf(sin(passo)) * 2.0 if andando else 0.0
	parado.position.y = -altura_pulo - balanco
	parado.rotation = sin(passo) * 0.06 if andando else 0.0


func posicionar(p: Vector2) -> void:
	logico = p
	position = Mapa.iso(logico)
	camera.reset_smoothing()


func _draw() -> void:
	if sprite or parado:
		Desenhos.elipse(self, Vector2.ZERO, 8, 2.5, Color(0, 0, 0, 0.35))
	else:
		draw_set_transform(Vector2(0, -_altura_pulo_atual()))
		Desenhos.coelho(self, direcao, passo, andando)
		draw_set_transform(Vector2.ZERO)
	if pulo >= 0.0:
		Desenhos.elipse(self, Vector2.ZERO, 7, 2, Color(0, 0, 0, 0.25))


func _altura_pulo_atual() -> float:
	return sin(clampf(pulo / 0.5, 0.0, 1.0) * PI) * 14.0 if pulo >= 0.0 else 0.0
