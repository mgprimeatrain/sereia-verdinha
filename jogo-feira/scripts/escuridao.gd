class_name Escuridao
extends Node2D
## Deixa a sala escura, com luz em volta do coelho (lanterna) e dos objetos.
## A luz é suave, com um pontilhado de pixel art na borda.

const SHADER := """
shader_type canvas_item;
uniform vec2 jogador;
uniform float raio_jogador = 95.0;
uniform vec4 luzes[16];
uniform int total_luzes = 0;
uniform float escuridao = 0.93;
uniform vec3 tom : source_color = vec3(0.025, 0.015, 0.01);
varying vec2 pos;
void vertex() { pos = VERTEX; }
float pontilhado(vec2 p) {
	return fract(52.9829189 * fract(dot(p, vec2(0.06711056, 0.00583715))));
}
void fragment() {
	vec2 p = floor(pos);
	float d = distance(p * vec2(1.0, 1.25), jogador * vec2(1.0, 1.25));
	float luz = pow(1.0 - smoothstep(0.0, raio_jogador, d), 1.4);
	for (int i = 0; i < total_luzes; i++) {
		float dl = distance(p, luzes[i].xy);
		float tremida = 1.0 + 0.07 * sin(TIME * (9.0 + float(i)) + float(i) * 1.7) + 0.05 * sin(TIME * 4.3 + float(i));
		luz += pow(1.0 - smoothstep(0.0, luzes[i].z * tremida, dl), 1.6) * luzes[i].w;
	}
	luz = clamp(luz, 0.0, 1.0);
	// pontilhado de pixel art na transição entre luz e sombra
	luz = clamp(luz + (pontilhado(p) - 0.5) * 0.08, 0.0, 1.0);
	luz = floor(luz * 14.0 + 0.5) / 14.0;
	COLOR = vec4(tom, escuridao * (1.0 - luz));
}
"""

var tamanho := Vector2.ZERO
var luzes: Array[Vector4] = []
var alvo: Node2D
var tempo := 0.0
var _material: ShaderMaterial


func configurar(tamanho_sala: Vector2) -> void:
	tamanho = tamanho_sala
	z_index = 50
	var shader := Shader.new()
	shader.code = SHADER
	_material = ShaderMaterial.new()
	_material.shader = shader
	material = _material


## Adiciona uma luz parada (posição, raio, força).
func adicionar_luz(posicao: Vector2, raio: float, forca: float) -> void:
	if luzes.size() < 16:
		luzes.append(Vector4(posicao.x, posicao.y, raio, forca))
		_material.set_shader_parameter("luzes", luzes)
		_material.set_shader_parameter("total_luzes", luzes.size())


func _process(delta: float) -> void:
	tempo += delta
	if alvo and alvo.is_inside_tree():
		_material.set_shader_parameter("jogador", alvo.global_position + Vector2(0, -12))
	_material.set_shader_parameter("raio_jogador", 95.0 + sin(tempo * 7.0) * 1.5 + sin(tempo * 2.3) * 2.5)


func _draw() -> void:
	draw_rect(Rect2(Vector2(-400, -400), tamanho + Vector2(800, 800)), Color.WHITE)


## Brilho colorido (somado à cor de baixo), para objetos e portas.
static func brilho(cor: Color, raio: float, forca: float) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = Desenhos.textura_luz()
	s.scale = Vector2.ONE * (raio * 2.0 / 256.0)
	s.modulate = Color(cor, forca)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	s.material = mat
	s.z_index = 60
	return s
