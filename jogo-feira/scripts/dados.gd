class_name Dados
extends RefCounted
## Todo o conteúdo do jogo fica aqui: o mapa, as salas e os componentes.
##
## O mapa é uma grade de células (cada célula é um quadradinho do chão).
## As posições abaixo são em células: Vector2i(coluna, linha).
## Na tela, a grade aparece inclinada (na diagonal).
##
## Para adicionar um componente novo:
##   1. crie uma entrada em COMPONENTES (copie uma que já existe);
##   2. coloque o id dele em OBJETOS, com a célula onde ele fica.

const TAMANHO_MAPA := Vector2i(40, 36)
const INICIO := Vector2i(20, 21)

## Cada sala é um retângulo de chão: Rect2i(coluna, linha, largura, altura).
const SALAS := {
	"laboratorio": {
		"nome": "Laboratório do Coelho", "area": Rect2i(14, 14, 12, 10),
		"papel": Color("efe2c4"), "madeira": Color("d9a86c"), "tapete": Color("e0664f"),
	},
	"energia": {
		"nome": "Sala da Energia", "area": Rect2i(2, 14, 10, 10),
		"papel": Color("f6dc8a"), "madeira": Color("d29a5c"), "tapete": Color("f0a830"),
	},
	"telas": {
		"nome": "Sala das Telas", "area": Rect2i(28, 14, 10, 10),
		"papel": Color("dccff0"), "madeira": Color("c99a70"), "tapete": Color("9c6fd6"),
	},
	"processamento": {
		"nome": "Sala do Processamento", "area": Rect2i(15, 2, 10, 10),
		"papel": Color("c6ecd6"), "madeira": Color("cfa070"), "tapete": Color("4fbf7f"),
	},
	"museu": {
		"nome": "Museu da Tecnologia", "area": Rect2i(12, 26, 16, 8),
		"papel": Color("f0c6b4"), "madeira": Color("c08a58"), "tapete": Color("c8463c"),
	},
	"lixo": {
		"nome": "Ferro-Velho Eletrônico", "area": Rect2i(29, 26, 10, 8),
		"papel": Color("d6d2c4"), "madeira": Color("b8a890"), "tapete": Color(0, 0, 0, 0),
	},
}

## Passagens que ligam as salas (buracos nas paredes).
const PASSAGENS := [
	Rect2i(12, 18, 2, 2),  # energia - laboratório
	Rect2i(26, 18, 2, 2),  # laboratório - telas
	Rect2i(19, 12, 2, 2),  # processamento - laboratório
	Rect2i(19, 24, 2, 2),  # laboratório - museu
	Rect2i(32, 24, 2, 2),  # telas - lixo
]

## Componentes que dá para inspecionar.
const OBJETOS := [
	["boas_vindas", Vector2i(18, 17)],
	["pilha_alcalina", Vector2i(4, 17)], ["bateria_litio", Vector2i(7, 20)], ["painel_solar", Vector2i(9, 16)],
	["wafer", Vector2i(17, 5)], ["transistor", Vector2i(22, 5)], ["processador", Vector2i(17, 9)],
	["tela_lcd", Vector2i(30, 16)], ["tela_oled", Vector2i(35, 16)], ["tela_touch", Vector2i(29, 21)],
	["placa_velha", Vector2i(30, 28)], ["bateria_inchada", Vector2i(36, 28)], ["pilhas_usadas", Vector2i(33, 31)],
	["pilha_volta", Vector2i(14, 28)], ["valvula", Vector2i(17, 31)], ["tv_tubo", Vector2i(23, 31)], ["disquete", Vector2i(26, 28)],
]

## Decoração. No chão: estante, bancada, armario, caixas, mesa_vela, lampiao,
## cabos, barril, sucata. Na parede (use a célula da parede): quadro, janela, tabela.
const MOVEIS := [
	# laboratório
	["estante", Vector2i(14, 14)], ["bancada", Vector2i(23, 14)], ["armario", Vector2i(25, 15)],
	["mesa_vela", Vector2i(15, 22)], ["caixas", Vector2i(24, 22)], ["cabos", Vector2i(22, 19)],
	["quadro", Vector2i(16, 13)], ["tabela", Vector2i(22, 13)], ["janela", Vector2i(13, 16)],
	# energia
	["estante", Vector2i(2, 14)], ["bancada", Vector2i(6, 14)], ["lampiao", Vector2i(10, 14)],
	["mesa_vela", Vector2i(3, 22)], ["caixas", Vector2i(10, 22)], ["cabos", Vector2i(6, 18)],
	["janela", Vector2i(4, 13)], ["tabela", Vector2i(8, 13)], ["quadro", Vector2i(1, 19)],
	# telas
	["estante", Vector2i(28, 14)], ["armario", Vector2i(33, 14)], ["bancada", Vector2i(36, 14)],
	["caixas", Vector2i(37, 22)], ["lampiao", Vector2i(36, 20)], ["cabos", Vector2i(34, 19)],
	["quadro", Vector2i(30, 13)], ["janela", Vector2i(27, 16)],
	# processamento
	["bancada", Vector2i(16, 2)], ["estante", Vector2i(20, 2)], ["bancada", Vector2i(23, 2)],
	["caixas", Vector2i(23, 10)], ["mesa_vela", Vector2i(15, 10)], ["cabos", Vector2i(21, 8)],
	["tabela", Vector2i(18, 1)], ["quadro", Vector2i(22, 1)], ["janela", Vector2i(14, 6)],
	# museu
	["estante", Vector2i(12, 26)], ["armario", Vector2i(16, 26)], ["armario", Vector2i(23, 26)],
	["estante", Vector2i(27, 26)], ["mesa_vela", Vector2i(20, 30)], ["lampiao", Vector2i(12, 32)],
	["caixas", Vector2i(27, 32)], ["quadro", Vector2i(14, 25)], ["janela", Vector2i(24, 25)],
	["tabela", Vector2i(11, 29)],
	# lixo eletrônico
	["barril", Vector2i(29, 26)], ["sucata", Vector2i(35, 26)], ["lampiao", Vector2i(31, 26)],
	["sucata", Vector2i(38, 30)], ["barril", Vector2i(38, 33)], ["barril", Vector2i(37, 33)],
	["caixas", Vector2i(29, 32)], ["cabos", Vector2i(34, 29)], ["janela", Vector2i(37, 25)],
]

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
	for item in OBJETOS:
		if conta(item[0]):
			total += 1
	return total
