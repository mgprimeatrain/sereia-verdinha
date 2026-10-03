class_name Jogador
extends Node2D
## O Coelho Cientista: anda com WASD/setas, corre com Shift, pula com Espaço
## e carrega a câmera.
##
## Imagens do coelho: coloque na pasta arte/ (PNG com fundo transparente)
## arquivos com o nome   coelho_<ação>_<direção>_<colunas>x<linhas>.png
## (a ação e a direção podem vir em qualquer ordem)
##   ação:     parado, andando, correndo, pulando
##   direção:  frente, costas, lado   (o de lado virado para a DIREITA)
##   grade:    quantos quadros a folha tem (ex.: 8x3). Imagem com um quadro só
##             pode ficar sem a grade, ex.: coelho_parado_frente.png
## Exemplos: coelho_andando_frente_8x3.png, coelho_pulando_lado_12x2.png
## O que faltar é trocado pela imagem mais parecida que existir. Sem nenhuma
## imagem, o jogo usa o coelho desenhado por código.
## O fundo branco e o desalinhamento dos quadros são arrumados sozinhos (recorte.gd).

const VELOCIDADE := 75.0
const VELOCIDADE_CORRENDO := 130.0
const ALTURA_COELHO := 34.0  # altura do coelho em pixels do jogo
const PASTA := "res://arte/"
const ACOES := ["parado", "andando", "correndo", "pulando"]
const VISTAS := ["frente", "costas", "lado"]
const FPS := {"parado": 8, "andando": 24, "correndo": 30, "pulando": 24}
## nomes antigos (sem ação ou sem direção) continuam funcionando
const NOMES_ANTIGOS := {
	"andando": ["andando_lado", Vector2i(8, 3)],
	"correndo": ["correndo_lado", Vector2i(7, 3)],
	"pulando": ["pulando_lado", Vector2i(12, 2)],
	"frente": ["parado_frente", Vector2i(1, 1)],
	"costas": ["parado_costas", Vector2i(1, 1)],
	"lado": ["parado_lado", Vector2i(1, 1)],
}

var mapa: Mapa
var logico := Vector2.ZERO  # posição na grade reta do mapa
var direcao := Vector2.DOWN  # direção na tela
var andando := false
var passo := 0.0
var correndo := false
var pulo := 0.0  # tempo desde o começo do pulo (< 0 = no chão)
var camera: Camera2D
var olhar_atual := Vector2.ZERO  # a câmera olha um pouco para onde o coelho anda
var camera_real := Vector2.ZERO  # posição da câmera sem arredondar
var fracao := Vector2.ZERO  # pedacinho de pixel que a tela compensa (ver main.gd)
var sprite: AnimatedSprite2D
var alturas := {}  # animação -> altura do quadro (para ajustar o tamanho)


func _ready() -> void:
	# Câmera estilo Enigma do Medo: segue solta, com atraso,
	# e olha um pouco para onde o coelho está andando.
	# A câmera anda em pixels inteiros (junto com o mundo) e o pedacinho que sobra
	# é compensado movendo a tela inteira (main.gd): assim nada treme.
	camera = Camera2D.new()
	camera.top_level = true
	add_child(camera)

	pulo = -1.0
	_carregar_sprites()


func _carregar_sprites() -> void:
	var pasta := DirAccess.open(PASTA)
	if pasta == null:
		return
	var quadros := SpriteFrames.new()
	quadros.remove_animation("default")
	var vistos := {}
	for arquivo in pasta.get_files():
		var nome := arquivo.trim_suffix(".import").trim_suffix(".remap")
		if not nome.ends_with(".png") or not nome.begins_with("coelho_") or nome.begins_with("coelho_rosto") or vistos.has(nome):
			continue
		vistos[nome] = true
		var partes := nome.get_basename().trim_prefix("coelho_").split("_")
		var grade := Vector2i(1, 1)
		var ultima := partes[partes.size() - 1]
		var tem_grade := ultima.contains("x") and ultima.get_slice("x", 0).is_valid_int() and ultima.get_slice("x", 1).is_valid_int()
		if tem_grade:
			grade = Vector2i(ultima.get_slice("x", 0).to_int(), ultima.get_slice("x", 1).to_int())
			partes.remove_at(partes.size() - 1)
		var chave := "_".join(partes)
		if NOMES_ANTIGOS.has(chave):
			if not tem_grade:
				grade = NOMES_ANTIGOS[chave][1]
			chave = NOMES_ANTIGOS[chave][0]
		# aceita as duas ordens: coelho_andando_frente e coelho_frente_andando
		var acao := ""
		var olhando := ""
		for parte in chave.split("_"):
			if parte in ACOES:
				acao = parte
			elif parte in VISTAS:
				olhando = parte
		if acao == "" or olhando == "":
			push_warning("Sprite com nome que o jogo não entendeu: " + nome)
			continue
		chave = acao + "_" + olhando
		if quadros.has_animation(chave):
			continue
		var folha: Texture2D = load(PASTA + nome)
		if folha == null:
			continue
		var preparado := Recorte.preparar(folha, grade, ALTURA_COELHO)
		quadros.add_animation(chave)
		quadros.set_animation_speed(chave, FPS[acao])
		quadros.set_animation_loop(chave, acao != "pulando")
		for quadro in preparado["quadros"]:
			quadros.add_frame(chave, quadro)
		alturas[chave] = preparado["altura"]
	print("Sprites do coelho carregados: ", quadros.get_animation_names())
	if quadros.get_animation_names().is_empty():
		return
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = quadros
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	_animar(0.0)  # já começa com a animação certa (parado, de frente)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pular") and pulo < 0.0:
		pulo = 0.0


func _process(delta: float) -> void:
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
	position = Mapa.iso(logico).round()
	olhar_atual = olhar_atual.lerp(entrada * Vector2(20, 12), 1.0 - exp(-delta * 1.5))

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


## Acha a animação que existe mais parecida com a ação e a direção pedidas.
func _escolher(acao: String, olhando: String) -> String:
	var acoes := [acao]
	if acao == "correndo" or acao == "pulando":
		acoes.append("andando")
	acoes.append("parado")
	if acao == "parado":
		acoes.append("andando")  # parado sem imagem própria: 1º quadro da caminhada
	var vistas := [olhando]
	for v in ["lado", "frente", "costas"]:
		if v not in vistas:
			vistas.append(v)
	for v in vistas:
		for a in acoes:
			if sprite.sprite_frames.has_animation(a + "_" + v):
				return a + "_" + v
	return sprite.sprite_frames.get_animation_names()[0]


func _animar(altura_pulo: float) -> void:
	if sprite == null:
		return
	var acao := "parado"
	if pulo >= 0.0:
		acao = "pulando"
	elif correndo:
		acao = "correndo"
	elif andando:
		acao = "andando"
	var nome := _escolher(acao, vista())
	if sprite.animation != nome:
		sprite.play(nome)
		var altura: float = alturas[nome]
		sprite.offset = Vector2(0, -roundf(altura / 2.0))
	elif not sprite.is_playing() and not nome.begins_with("pulando"):
		sprite.play(nome)
	if acao == "parado" and nome.begins_with("andando"):
		sprite.stop()
		sprite.frame = 0
	if nome.ends_with("_lado") and absf(direcao.x) > 0.1:
		sprite.flip_h = direcao.x < 0
	elif not nome.ends_with("_lado"):
		sprite.flip_h = false

	# imagem de um quadro só: balança um pouquinho para parecer que anda
	var um_quadro := sprite.sprite_frames.get_frame_count(nome) == 1
	var balanco := absf(sin(passo)) * 2.0 if andando and um_quadro else 0.0
	sprite.position.y = -altura_pulo - balanco
	sprite.rotation = sin(passo) * 0.06 if andando and um_quadro else 0.0


func posicionar(p: Vector2) -> void:
	logico = p
	position = Mapa.iso(logico).round()
	camera_real = _alvo_da_camera()
	atualizar_camera(0.0)


func _alvo_da_camera() -> Vector2:
	return position + Vector2(0, -14) + olhar_atual


## Chamada pelo main.gd a cada quadro (mesmo com o jogo pausado).
func atualizar_camera(delta: float) -> void:
	camera_real = camera_real.lerp(_alvo_da_camera(), 1.0 - exp(-delta * 3.5))
	var inteiro := camera_real.floor()
	camera.global_position = inteiro
	fracao = camera_real - inteiro


func _draw() -> void:
	# sombra (fica menor quando o coelho está no ar)
	var no_ar := _altura_pulo_atual() / 14.0
	Desenhos.elipse(self, Vector2(1, 0), 11.0 - no_ar * 4.0, 3.5 - no_ar, Desenhos.SOMBRA)
	if not sprite:
		draw_set_transform(Vector2(0, -_altura_pulo_atual()))
		Desenhos.coelho(self, direcao, passo, andando)
		draw_set_transform(Vector2.ZERO)


func _altura_pulo_atual() -> float:
	return sin(clampf(pulo / 0.5, 0.0, 1.0) * PI) * 14.0 if pulo >= 0.0 else 0.0
