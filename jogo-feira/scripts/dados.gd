class_name Dados
extends RefCounted
## Todo o conteúdo do jogo fica aqui: as salas e os componentes.
## Para adicionar um componente novo:
##   1. crie uma entrada em COMPONENTES (copie uma que já existe);
##   2. coloque o id dele na lista "objetos" de alguma sala, com a posição.
## O chão das salas começa em y = 64 (abaixo da parede do fundo).
##
## "moveis" são a decoração. Tipos: estante, bancada, armario, caixas,
## mesa_vela, lampiao, cabos, barril, sucata (no chão) e quadro, janela,
## tabela (penduradas na parede: só o x importa).

const SALA_INICIAL := "laboratorio"

const SALAS := {
	"laboratorio": {
		"nome": "Laboratório do Coelho",
		"curto": "Laboratório",
		"tamanho": Vector2(448, 320),
		"cor": Color("e0a050"),
		"papel": Color("3a2a1e"),
		"madeira": Color("4a3020"),
		"tapete": Color("3a1a14"),
		"portas": {"cima": "processamento", "esquerda": "energia", "direita": "telas", "baixo": "museu"},
		"objetos": [["boas_vindas", Vector2(224, 160)]],
		"moveis": [
			["estante", Vector2(56, 74)], ["quadro", Vector2(130, 0)], ["bancada", Vector2(330, 78)],
			["armario", Vector2(408, 74)], ["mesa_vela", Vector2(70, 262)], ["caixas", Vector2(392, 272)],
			["cabos", Vector2(320, 200)],
		],
	},
	"energia": {
		"nome": "Sala da Energia",
		"curto": "Energia",
		"tamanho": Vector2(512, 288),
		"cor": Color("f0b040"),
		"papel": Color("3d2c18"),
		"madeira": Color("4a3220"),
		"tapete": Color("33280f"),
		"portas": {"direita": "laboratorio"},
		"objetos": [
			["pilha_alcalina", Vector2(120, 150)],
			["bateria_litio", Vector2(256, 215)],
			["painel_solar", Vector2(390, 140)],
		],
		"moveis": [
			["estante", Vector2(56, 74)], ["janela", Vector2(160, 0)], ["bancada", Vector2(256, 78)],
			["tabela", Vector2(380, 0)], ["lampiao", Vector2(462, 92)], ["mesa_vela", Vector2(80, 252)],
			["caixas", Vector2(440, 262)], ["cabos", Vector2(180, 250)],
		],
	},
	"processamento": {
		"nome": "Sala do Processamento",
		"curto": "Processamento",
		"tamanho": Vector2(448, 352),
		"cor": Color("9ad060"),
		"papel": Color("2a2a1c"),
		"madeira": Color("3e2c1e"),
		"tapete": Color("1c2416"),
		"portas": {"baixo": "laboratorio"},
		"objetos": [
			["wafer", Vector2(110, 160)],
			["transistor", Vector2(338, 160)],
			["processador", Vector2(224, 240)],
		],
		"moveis": [
			["bancada", Vector2(100, 78)], ["estante", Vector2(224, 74)], ["bancada", Vector2(340, 78)],
			["armario", Vector2(416, 74)], ["mesa_vela", Vector2(50, 312)], ["caixas", Vector2(396, 312)],
			["cabos", Vector2(150, 300)],
		],
	},
	"telas": {
		"nome": "Sala das Telas",
		"curto": "Telas",
		"tamanho": Vector2(512, 288),
		"cor": Color("d080e0"),
		"papel": Color("2e2024"),
		"madeira": Color("402a20"),
		"tapete": Color("2c1622"),
		"portas": {"esquerda": "laboratorio", "direita": "lixo"},
		"objetos": [
			["tela_lcd", Vector2(140, 135)],
			["tela_oled", Vector2(372, 135)],
			["tela_touch", Vector2(256, 230)],
		],
		"moveis": [
			["estante", Vector2(56, 74)], ["quadro", Vector2(170, 0)], ["armario", Vector2(256, 74)],
			["janela", Vector2(350, 0)], ["bancada", Vector2(448, 78)], ["caixas", Vector2(50, 262)],
			["lampiao", Vector2(462, 250)], ["cabos", Vector2(330, 190)],
		],
	},
	"lixo": {
		"nome": "Ferro-Velho Eletrônico",
		"curto": "Lixo Eletrônico",
		"tamanho": Vector2(480, 320),
		"cor": Color("b0c040"),
		"papel": Color("2c2a1a"),
		"madeira": Color("3a3020"),
		"tapete": Color("00000000"),
		"portas": {"esquerda": "telas"},
		"objetos": [
			["placa_velha", Vector2(150, 140)],
			["bateria_inchada", Vector2(330, 150)],
			["pilhas_usadas", Vector2(240, 250)],
		],
		"moveis": [
			["barril", Vector2(44, 86)], ["sucata", Vector2(230, 80)], ["sucata", Vector2(420, 84)],
			["lampiao", Vector2(120, 86)], ["barril", Vector2(440, 280)], ["barril", Vector2(416, 290)],
			["caixas", Vector2(70, 290)], ["cabos", Vector2(340, 240)], ["sucata", Vector2(380, 220)],
		],
	},
	"museu": {
		"nome": "Museu da Tecnologia",
		"curto": "Museu",
		"tamanho": Vector2(576, 288),
		"cor": Color("e0a060"),
		"papel": Color("3a1a16"),
		"madeira": Color("4a2e1c"),
		"tapete": Color("3c1612"),
		"portas": {"cima": "laboratorio"},
		"objetos": [
			["pilha_volta", Vector2(100, 150)],
			["valvula", Vector2(220, 220)],
			["tv_tubo", Vector2(356, 220)],
			["disquete", Vector2(476, 150)],
		],
		"moveis": [
			["estante", Vector2(48, 74)], ["quadro", Vector2(140, 0)], ["armario", Vector2(220, 74)],
			["armario", Vector2(356, 74)], ["janela", Vector2(440, 0)], ["estante", Vector2(528, 74)],
			["mesa_vela", Vector2(288, 262)], ["lampiao", Vector2(40, 250)], ["caixas", Vector2(540, 262)],
		],
	},
}

## "forma" escolhe o desenho provisório (veja desenhos.gd).
## "destaque" aparece grande na janela de inspeção (de preferência um elemento químico).
## "conta": false faz o objeto não entrar na coleção.
## Se existir uma imagem em res://arte/componentes/<id>.png, ela é usada no lugar do desenho.
const COMPONENTES := {
	"boas_vindas": {
		"nome": "Placa de boas-vindas",
		"forma": "aviso",
		"cor": Color("c9a874"),
		"destaque": "?",
		"conta": false,
		"texto": "Olá! Eu sou o Coelho Cientista e este é o meu laboratório. Cada porta leva a uma sala cheia de aparelhos eletrônicos. Chegue perto deles e aperte E para descobrir a química escondida dentro de cada um!",
		"curiosidade": "Tem {total} componentes espalhados pelas salas, inclusive no Museu, com aparelhos bem antigos. Será que você encontra todos?",
	},

	# ---------- ENERGIA ----------
	"pilha_alcalina": {
		"nome": "Pilha alcalina",
		"forma": "pilha",
		"cor": Color("e0a526"),
		"destaque": "Zn",
		"texto": "Dentro da pilha acontece uma reação química: o zinco (Zn) solta elétrons e o dióxido de manganês recebe esses elétrons. Esse \"passa-passa\" de elétrons se chama oxirredução, e é ele que gera a corrente elétrica que liga o controle remoto.",
		"curiosidade": "Ela se chama \"alcalina\" porque tem por dentro uma substância básica (alcalina): o hidróxido de potássio.",
	},
	"bateria_litio": {
		"nome": "Bateria de íon-lítio",
		"forma": "bateria",
		"cor": Color("4aa3df"),
		"destaque": "Li",
		"texto": "A bateria do celular guarda energia usando íons de lítio (Li). Quando você carrega o celular, os íons viajam para um lado da bateria (o grafite). Quando você usa, eles voltam para o outro lado e liberam energia. Por isso dá para recarregar muitas vezes!",
		"curiosidade": "O lítio é o metal mais leve que existe. Ele é tão leve que boiaria na água (mas não tente: ele reage com ela!).",
	},
	"painel_solar": {
		"nome": "Painel solar",
		"forma": "painel",
		"cor": Color("3d5bd9"),
		"destaque": "Si",
		"texto": "O painel solar é feito de silício (Si), o mesmo material dos chips. Quando a luz do Sol bate nele, ela empurra os elétrons do silício e cria corrente elétrica, sem fumaça e sem barulho.",
		"curiosidade": "O silício vem da areia! A areia é feita principalmente de dióxido de silício, que é purificado até virar o painel.",
	},

	# ---------- PROCESSAMENTO ----------
	"wafer": {
		"nome": "Wafer de silício",
		"forma": "disco",
		"cor": Color("8f86c9"),
		"destaque": "Si",
		"texto": "Os chips nascem em um disco chamado wafer, feito de silício (Si) super puro: 99,9999999% de pureza! Os circuitos são \"desenhados\" nele usando luz e produtos químicos, e depois o disco é cortado em centenas de chips.",
		"curiosidade": "As fábricas de chips são tão limpas que um único grão de poeira pode estragar um chip. Os trabalhadores usam roupas que parecem de astronauta!",
	},
	"transistor": {
		"nome": "Transistor",
		"forma": "transistor",
		"cor": Color("e05a5a"),
		"destaque": "P  B",
		"texto": "O transistor é um interruptor minúsculo que liga e desliga a eletricidade. O segredo é a dopagem: colocar no silício um pouquinho de fósforo (P), que traz elétrons a mais, ou de boro (B), que deixa \"buracos\" sem elétrons.",
		"curiosidade": "O chip de um celular moderno tem mais de 10 bilhões de transistores. É mais do que o número de pessoas na Terra!",
	},
	"processador": {
		"nome": "Processador (CPU)",
		"forma": "cpu",
		"cor": Color("d4af37"),
		"destaque": "Cu",
		"texto": "O processador é o \"cérebro\" do computador. Dentro dele, bilhões de transistores são ligados por fios de cobre (Cu) milhares de vezes mais finos que um fio de cabelo. Os contatos costumam ser banhados a ouro (Au), que não enferruja.",
		"curiosidade": "Ele esquenta tanto trabalhando que precisa de pasta térmica e de um ventilador (cooler) para não queimar.",
	},

	# ---------- TELAS ----------
	"tela_lcd": {
		"nome": "Tela LCD",
		"forma": "tela",
		"cor": Color("6aa8ff"),
		"destaque": "LCD",
		"texto": "A tela LCD usa cristais líquidos: substâncias que são meio líquido, meio sólido. Quando passa eletricidade, as moléculas giram e deixam a luz de trás da tela passar ou bloqueiam essa luz, formando a imagem.",
		"curiosidade": "Os cristais líquidos foram descobertos em 1888, estudando uma substância tirada da cenoura!",
	},
	"tela_oled": {
		"nome": "Tela OLED",
		"forma": "tela",
		"cor": Color("e04ad6"),
		"destaque": "C",
		"texto": "OLED quer dizer \"LED orgânico\". Na química, orgânico quer dizer feito de carbono (C). Cada pontinho da tela é uma camada de moléculas de carbono que brilha sozinha quando passa corrente elétrica.",
		"curiosidade": "Na tela OLED, o preto é o pontinho totalmente apagado. Por isso usar o modo escuro economiza bateria!",
	},
	"tela_touch": {
		"nome": "Tela touch",
		"forma": "celular",
		"cor": Color("6fd3ff"),
		"destaque": "In",
		"texto": "A tela touch tem uma camada invisível de óxido de índio e estanho (In e Sn), que é transparente e conduz eletricidade. Seu dedo também conduz (ele tem água e sais), então quando você toca, o celular sente a mudança e sabe onde foi.",
		"curiosidade": "É por isso que a tela não funciona com luva comum... mas funciona com uma salsicha!",
	},

	# ---------- LIXO ELETRÔNICO ----------
	"placa_velha": {
		"nome": "Placa de circuito velha",
		"forma": "placa",
		"cor": Color("2f8f46"),
		"destaque": "Au",
		"texto": "Placas de aparelhos velhos têm metais valiosos: ouro (Au), prata (Ag) e cobre (Cu). Na reciclagem, a química é usada para separar e recuperar esses metais, que voltam a ser usados em aparelhos novos.",
		"curiosidade": "Uma tonelada de celulares velhos tem muito mais ouro do que uma tonelada de pedras tiradas de uma mina de ouro!",
	},
	"bateria_inchada": {
		"nome": "Bateria estufada",
		"forma": "inchada",
		"cor": Color("c9c23a"),
		"destaque": "Li",
		"texto": "Quando uma bateria de lítio envelhece ou estraga, reações químicas dentro dela podem formar gases, e ela incha. Ela pode até pegar fogo! Nunca fure uma bateria e nunca jogue no lixo comum.",
		"curiosidade": "Pilhas e baterias devem ir para pontos de coleta. Muitas lojas e supermercados têm um!",
	},
	"pilhas_usadas": {
		"nome": "Pilhas e baterias usadas",
		"forma": "pilhas",
		"cor": Color("c08a3e"),
		"destaque": "Cd",
		"texto": "Algumas pilhas e baterias, principalmente as antigas, têm metais pesados como cádmio (Cd), chumbo (Pb) e mercúrio (Hg). Jogadas no lixo comum, elas podem contaminar o solo e a água por muitos anos.",
		"curiosidade": "No Brasil, a lei obriga quem vende pilhas e baterias a receber as usadas de volta para dar o destino certo.",
	},

	# ---------- MUSEU (ANTIGOS) ----------
	"pilha_volta": {
		"nome": "Pilha de Volta (1800)",
		"forma": "volta",
		"cor": Color("b87333"),
		"destaque": "Zn Cu",
		"texto": "Em 1800, o cientista italiano Alessandro Volta empilhou discos de zinco (Zn) e cobre (Cu), separados por panos molhados com água salgada. Foi a primeira pilha elétrica da história!",
		"curiosidade": "A unidade \"volt\", que aparece escrita nas pilhas e nas tomadas, é uma homenagem a Volta.",
	},
	"valvula": {
		"nome": "Válvula (anos 1940)",
		"forma": "valvula",
		"cor": Color("ff9a3c"),
		"destaque": "W",
		"texto": "Antes dos transistores, os aparelhos usavam válvulas: tubos de vidro sem ar, com um filamento de metal (como o tungstênio, W) que esquenta e solta elétrons. Elas funcionavam como interruptores, mas eram grandes e esquentavam muito.",
		"curiosidade": "O ENIAC, um dos primeiros computadores (1946), tinha cerca de 18 mil válvulas e pesava 27 toneladas!",
	},
	"tv_tubo": {
		"nome": "TV de tubo",
		"forma": "tv",
		"cor": Color("8fd18f"),
		"destaque": "Pb",
		"texto": "A TV de tubo atirava elétrons na tela, que era pintada por dentro com substâncias que brilham quando são atingidas (chamadas de fósforos). O vidro tinha chumbo (Pb) para segurar a radiação.",
		"curiosidade": "Por causa do vidro com chumbo, uma TV de tubo grande podia pesar mais de 50 kg!",
	},
	"disquete": {
		"nome": "Disquete",
		"forma": "disquete",
		"cor": Color("3a4f9f"),
		"destaque": "Fe",
		"texto": "O disquete guardava arquivos em um disco de plástico coberto com óxido de ferro (Fe), um pó magnético parecido com ferrugem. Os dados eram gravados magnetizando pedacinhos desse pó.",
		"curiosidade": "Um disquete guardava só 1,44 MB: uma única foto de celular hoje não caberia nele! O ícone de \"salvar\" dos programas é um disquete.",
	},
}


static func conta(id: String) -> bool:
	return COMPONENTES[id].get("conta", true)


static func total_componentes() -> int:
	var total := 0
	for sala in SALAS.values():
		for item in sala["objetos"]:
			if conta(item[0]):
				total += 1
	return total
