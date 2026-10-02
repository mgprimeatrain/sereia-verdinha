class_name Escuridao
extends Node2D
## Deixa a sala escura, com luz em volta do coelho (lanterna) e dos objetos.
## A luz é feita em "faixas", como nos jogos de pixel art.

const SHADER := """
shader_type canvas_item;
uniform vec2 jogador;
uniform float raio_jogador = 110.0;
uniform vec4 luzes[12];
uniform int total_luzes = 0;
uniform float escuridao = 0.6;
uniform vec3 tom : source_color = vec3(0.02, 0.02, 0.05);
varying vec2 pos;
void vertex() { pos = VERTEX; }
void fragment() {
	vec2 p = floor(pos);
	float luz = 1.0 - smoothstep(raio_jogador * 0.3, raio_jogador, distance(p, jogador));
	for (int i = 0; i < total_luzes; i++) {
		float d = distance(p, luzes[i].xy);
		luz += (1.0 - smoothstep(luzes[i].z * 0.2, luzes[i].z, d)) * luzes[i].w;
	}
	luz = clamp(luz, 0.0, 1.0);
	luz = floor(luz * 6.0 + 0.5) / 6.0;
	COLOR = vec4(tom, escuridao * (1.0 - luz));
}
"""

var tamanho := Vector2.ZERO
var luzes: Array[Vector4] = []
var alvo: Node2D
var tempo := 0.0
var _material: ShaderMaterial


func configurar(tamanho_sala: Vector2, ambiente: Color) -> void:
	tamanho = tamanho_sala
	z_index = 50
	var shader := Shader.new()
	shader.code = SHADER
	_material = ShaderMaterial.new()
	_material.shader = shader
	_material.set_shader_parameter("escuridao", clampf(1.0 - ambiente.get_luminance(), 0.3, 0.85))
	_material.set_shader_parameter("tom", ambiente.darkened(0.88))
	material = _material


## Adiciona uma luz parada (posição, raio, força).
func adicionar_luz(posicao: Vector2, raio: float, forca: float) -> void:
	if luzes.size() < 12:
		luzes.append(Vector4(posicao.x, posicao.y, raio, forca))
		_material.set_shader_parameter("luzes", luzes)
		_material.set_shader_parameter("total_luzes", luzes.size())


func _process(delta: float) -> void:
	tempo += delta
	if alvo and alvo.is_inside_tree():
		_material.set_shader_parameter("jogador", alvo.global_position + Vector2(0, -12))
	_material.set_shader_parameter("raio_jogador", 105.0 + sin(tempo * 7.0) * 2.0 + sin(tempo * 2.3) * 3.0)


func _draw() -> void:
	draw_rect(Rect2(Vector2(-64, -64), tamanho + Vector2(128, 128)), Color.WHITE)


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
