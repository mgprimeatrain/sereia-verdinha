class_name Recorte
extends RefCounted
## Arruma as folhas de sprite do coelho quando o jogo abre:
##   1. corta a folha em quadros e diminui para o tamanho do jogo;
##   2. apaga o fundo branco que fica FORA do contorno preto;
##   3. alinha todos os quadros pelos pés e pela cabeça (para não tremer);
##   4. deixa o coelho sempre com a mesma altura, em qualquer folha.

const MEDIDA := 64.0  # altura usada só para medir o coelho

static var _retrato: Texture2D


## O 1º quadro do coelho parado de frente, em tamanho grande e recortado
## (usado na tela de título e na caixa de fala). null se não tiver sprite.
static func retrato() -> Texture2D:
	if _retrato:
		return _retrato
	var pasta := DirAccess.open("res://arte/")
	if pasta == null:
		return null
	var melhor := ""
	var pontos := -1
	for arquivo in pasta.get_files():
		var nome := arquivo.trim_suffix(".import").trim_suffix(".remap")
		if not nome.ends_with(".png") or not nome.begins_with("coelho_") or nome.begins_with("coelho_rosto"):
			continue
		var p := (2 if "frente" in nome else 0) + (1 if "parado" in nome else 0)
		if p > pontos:
			pontos = p
			melhor = nome
	if melhor == "":
		return null
	var img: Image = (load("res://arte/" + melhor) as Texture2D).get_image()
	if img.is_compressed():
		img.decompress()
	var ultima := melhor.get_basename().get_slice("_", melhor.get_basename().get_slice_count("_") - 1)
	var grade := Vector2i(1, 1)
	if ultima.contains("x") and ultima.get_slice("x", 0).is_valid_int():
		grade = Vector2i(ultima.get_slice("x", 0).to_int(), ultima.get_slice("x", 1).to_int())
	var quadro := img.get_region(Rect2i(Vector2i.ZERO, Vector2i(img.get_width() / grade.x, img.get_height() / grade.y)))
	quadro = quadro.get_region(quadro.get_used_rect())
	_retrato = ImageTexture.create_from_image(quadro)
	return _retrato


## Devolve {"quadros": Array[Texture2D], "altura": altura do quadro final}.
static func preparar(folha: Texture2D, grade: Vector2i, altura_coelho: float) -> Dictionary:
	var img := folha.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var tam := Vector2i(img.get_width() / grade.x, img.get_height() / grade.y)

	# 1ª passada, pequena: descobre a altura do coelho dentro do quadro
	var escala := MEDIDA / tam.y
	var maior := 1
	for q in _cortar(img, grade, tam, escala):
		maior = maxi(maior, q["caixa"].size.y)
	# 2ª passada, no tamanho certo para o coelho ficar com altura_coelho
	escala *= altura_coelho / maior
	var cortes := _cortar(img, grade, tam, escala)

	# todos os quadros do mesmo tamanho, com a cabeça no meio e os pés embaixo
	var meia_largura := 1
	var altura := 1
	for q in cortes:
		var caixa: Rect2i = q["caixa"]
		meia_largura = maxi(meia_largura, maxi(q["centro"] - caixa.position.x, caixa.end.x - q["centro"]))
		altura = maxi(altura, caixa.size.y)
	var largura := meia_largura * 2 + 2
	var quadros: Array[Texture2D] = []
	for q in cortes:
		var caixa: Rect2i = q["caixa"]
		var final := Image.create(largura, altura, false, Image.FORMAT_RGBA8)
		if caixa.size.x > 0:
			var destino := Vector2i(largura / 2 - (q["centro"] - caixa.position.x), altura - caixa.size.y)
			final.blit_rect(q["imagem"], caixa, destino)
		quadros.append(ImageTexture.create_from_image(final))
	return {"quadros": quadros, "altura": float(altura)}


static func _cortar(img: Image, grade: Vector2i, tam: Vector2i, escala: float) -> Array:
	var cortes := []
	var novo := Vector2i(maxi(1, roundi(tam.x * escala)), maxi(1, roundi(tam.y * escala)))
	for linha in grade.y:
		for coluna in grade.x:
			var quadro := img.get_region(Rect2i(Vector2i(coluna, linha) * tam, tam))
			quadro.resize(novo.x, novo.y, Image.INTERPOLATE_NEAREST)
			_apagar_fundo(quadro)
			_limpar_bordas(quadro)
			var caixa := quadro.get_used_rect()
			cortes.append({"imagem": quadro, "caixa": caixa, "centro": _centro_da_cabeca(quadro, caixa)})
	return cortes


static func _eh_fundo(c: Color) -> bool:
	if c.a < 0.1:
		return true
	var menor := minf(c.r, minf(c.g, c.b))
	var maior := maxf(c.r, maxf(c.g, c.b))
	return menor > 0.8 and maior - menor < 0.1


## Pinta de transparente o branco ligado às bordas do quadro (o fundo).
## O branco de dentro do coelho fica, porque o contorno preto segura.
## Se a imagem já tem fundo transparente, não mexe em nada.
static func _apagar_fundo(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for canto in [Vector2i(0, 0), Vector2i(w - 1, 0), Vector2i(0, h - 1), Vector2i(w - 1, h - 1)]:
		if img.get_pixelv(canto).a < 0.1:
			return
	var visitado := PackedByteArray()
	visitado.resize(w * h)
	var pilha := PackedInt32Array()
	for x in w:
		pilha.append(x)
		pilha.append((h - 1) * w + x)
	for y in h:
		pilha.append(y * w)
		pilha.append(y * w + w - 1)
	var transparente := Color(0, 0, 0, 0)
	while not pilha.is_empty():
		var i := pilha[pilha.size() - 1]
		pilha.remove_at(pilha.size() - 1)
		if visitado[i] == 1:
			continue
		visitado[i] = 1
		var x := i % w
		var y := i / w
		if not _eh_fundo(img.get_pixel(x, y)):
			continue
		img.set_pixel(x, y, transparente)
		if x > 0: pilha.append(i - 1)
		if x < w - 1: pilha.append(i + 1)
		if y > 0: pilha.append(i - w)
		if y < h - 1: pilha.append(i + w)


## Deixa cada pixel ou totalmente visível ou totalmente transparente
## (tira o "fantasminha" em volta do contorno, para ficar pixel art nítida).
static func _limpar_bordas(img: Image) -> void:
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.5:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
			elif c.a < 1.0:
				c.a = 1.0
				img.set_pixel(x, y, c)


## Meio da cabeça (parte de cima do coelho), que quase não mexe ao andar.
static func _centro_da_cabeca(img: Image, caixa: Rect2i) -> int:
	if caixa.size.x == 0:
		return 0
	var soma := 0
	var conta := 0
	var fim := caixa.position.y + maxi(1, int(caixa.size.y * 0.4))
	for y in range(caixa.position.y, fim):
		for x in range(caixa.position.x, caixa.end.x):
			if img.get_pixel(x, y).a > 0.5:
				soma += x
				conta += 1
	return roundi(float(soma) / conta) if conta > 0 else caixa.get_center().x
