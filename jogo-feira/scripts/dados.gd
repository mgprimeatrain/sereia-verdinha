class_name Dados
extends RefCounted
## Todo o conteúdo do jogo fica aqui: o mapa, as salas e os componentes.
##
## Salas com "antigo": true têm chão de madeira, papel de parede e móveis antigos
## (o Museu); as outras são modernas, com piso claro. "escuro" (0 a 1) diz o quanto
## a sala fica no escuro (só as luzes iluminam).
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
		"fala": "Olá! Eu sou o Coelho Cientista! Vamos descobrir de que são feitos os celulares e computadores que a gente usa todo dia. Visite as salas, inspecione os objetos com E e, no fim, faça o quiz no terminal aqui do laboratório!",
		"nome": "Laboratório do Coelho", "area": Rect2i(14, 14, 12, 10),
		"papel": Color("eef0f2"), "madeira": Color("d6d9dd"), "tapete": Color("e0664f"),
	},
	"energia": {
		"fala": "Aqui é a sala da energia! O lítio trocou as baterias grandes e pesadas por baterias leves e que duram muito.",
		"nome": "Sala da Energia", "area": Rect2i(2, 14, 10, 10),
		"papel": Color("f6f0dc"), "madeira": Color("d8d6cf"), "tapete": Color("f0a830"),
	},
	"telas": {
		"fala": "Materiais especiais deixaram as telas melhores, mais finas e muito mais resistentes. Vamos ver como elas funcionam!",
		"nome": "Sala das Telas", "area": Rect2i(28, 14, 10, 10),
		"papel": Color("ebe6f4"), "madeira": Color("d6d4dc"), "tapete": Color("9c6fd6"),
	},
	"processamento": {
		"fala": "O silício é o \"cérebro\" dos chips: ele substituiu peças lentas e deixou os aparelhos rápidos e pequenos!",
		"nome": "Sala do Processamento", "area": Rect2i(15, 2, 10, 10),
		"papel": Color("e2f2e8"), "madeira": Color("d2d8d4"), "tapete": Color("4fbf7f"),
	},
	"museu": {
		"fala": "No começo, os aparelhos usavam muito ferro, vidro grosso e plástico comum. Eram pesados, grandes e lentos! Olha só como era antigamente.",
		"nome": "Museu da Tecnologia", "area": Rect2i(12, 26, 16, 8),
		"papel": Color("5a2a24"), "madeira": Color("6a4428"), "tapete": Color("6a1a18"),
		"antigo": true, "escuro": 0.72,
	},
	"computador": {
		"nome": "Sala do Computador", "area": Rect2i(2, 2, 10, 10),
		"fala": "Aqui ficam as peças de dentro do computador! Cada uma é feita de vários elementos químicos diferentes. Vamos ver quais?",
		"papel": Color("e2eaf4"), "madeira": Color("d0d4da"), "tapete": Color("4a90d9"),
	},
	"materiais": {
		"nome": "Sala dos Materiais", "area": Rect2i(27, 2, 10, 10),
		"fala": "A química transforma matérias-primas em peças de tecnologia. Cada material desta sala resolveu um problema dos aparelhos antigos!",
		"papel": Color("f4ebe4"), "madeira": Color("dcd6d0"), "tapete": Color("d08a3a"),
	},
	"lixo": {
		"fala": "Fabricar um aparelho começa com a extração de minerais, e isso pode prejudicar a natureza. Por isso a reciclagem é tão importante: ela recupera os materiais para usar de novo!",
		"nome": "Ferro-Velho Eletrônico", "area": Rect2i(29, 26, 10, 8),
		"papel": Color("e4e6e0"), "madeira": Color("c4c6c0"), "tapete": Color(0, 0, 0, 0),
	},
}

## Passagens que ligam as salas (buracos nas paredes).
const PASSAGENS := [
	Rect2i(12, 18, 2, 2),  # energia - laboratório
	Rect2i(26, 18, 2, 2),  # laboratório - telas
	Rect2i(19, 12, 2, 2),  # processamento - laboratório
	Rect2i(19, 24, 2, 2),  # laboratório - museu
	Rect2i(32, 24, 2, 2),  # telas - lixo
	Rect2i(25, 6, 2, 2),  # processamento - materiais
	Rect2i(12, 6, 3, 2),  # computador - processamento
]

## Componentes que dá para inspecionar.
const OBJETOS := [
	["boas_vindas", Vector2i(18, 17)], ["terminal_quiz", Vector2i(22, 17)],
	["fio_cobre", Vector2i(29, 5)], ["contato_ouro", Vector2i(34, 5)], ["plastico", Vector2i(32, 7)],
	["carcaca_aluminio", Vector2i(29, 9)], ["vidro_tela", Vector2i(34, 9)],
	["tijolao", Vector2i(21, 28)], ["radio", Vector2i(18, 28)], ["telefone", Vector2i(25, 30)],
	["ssd", Vector2i(4, 5)], ["hd", Vector2i(9, 5)], ["placa_video", Vector2i(4, 9)], ["memoria_ram", Vector2i(9, 9)], ["gabinete_ferro", Vector2i(15, 32)], ["minerio", Vector2i(36, 31)],
	["pilha_alcalina", Vector2i(4, 17)], ["bateria_litio", Vector2i(7, 20)], ["painel_solar", Vector2i(9, 16)],
	["wafer", Vector2i(17, 5)], ["transistor", Vector2i(22, 5)], ["processador", Vector2i(17, 9)],
	["tela_lcd", Vector2i(30, 16)], ["tela_oled", Vector2i(35, 16)], ["tela_touch", Vector2i(29, 21)],
	["placa_velha", Vector2i(30, 28)], ["bateria_inchada", Vector2i(36, 28)], ["pilhas_usadas", Vector2i(33, 31)],
	["pilha_volta", Vector2i(14, 28)], ["valvula", Vector2i(17, 31)], ["tv_tubo", Vector2i(23, 31)], ["disquete", Vector2i(26, 28)],
]

## Decoração.
## Antigos (Museu): estante, bancada, armario, mesa_vela, lampiao; na parede: quadro, janela.
## Modernos: estante_metal, bancada_moderna, armario_branco, luminaria, planta,
## servidor, lixeiras; na parede: lousa, tela_parede, janela_moderna.
## Em qualquer sala: caixas, cabos, barril, sucata; na parede: tabela.
const MOVEIS := [
	# laboratório
	["estante_metal", Vector2i(14, 14)], ["bancada_moderna", Vector2i(23, 14)], ["armario_branco", Vector2i(25, 15)],
	["planta", Vector2i(15, 22)], ["luminaria", Vector2i(24, 22)], ["planta", Vector2i(25, 21)],
	["lousa", Vector2i(16, 13)], ["tabela", Vector2i(22, 13)], ["janela_moderna", Vector2i(13, 16)],
	# energia
	["estante_metal", Vector2i(2, 14)], ["bancada_moderna", Vector2i(6, 14)], ["luminaria", Vector2i(10, 14)],
	["planta", Vector2i(3, 22)], ["caixas", Vector2i(10, 22)], ["cabos", Vector2i(6, 18)],
	["janela_moderna", Vector2i(4, 13)], ["tabela", Vector2i(8, 13)], ["tela_parede", Vector2i(1, 19)],
	# telas
	["estante_metal", Vector2i(28, 14)], ["armario_branco", Vector2i(33, 14)], ["bancada_moderna", Vector2i(36, 14)],
	["caixas", Vector2i(37, 22)], ["luminaria", Vector2i(36, 20)], ["planta", Vector2i(28, 22)],
	["tela_parede", Vector2i(30, 13)], ["janela_moderna", Vector2i(27, 16)],
	# processamento
	["bancada_moderna", Vector2i(16, 2)], ["servidor", Vector2i(20, 2)], ["servidor", Vector2i(21, 2)], ["bancada_moderna", Vector2i(23, 2)],
	["caixas", Vector2i(23, 10)], ["planta", Vector2i(15, 10)], ["cabos", Vector2i(21, 8)],
	["tabela", Vector2i(18, 1)], ["tela_parede", Vector2i(22, 1)], ["janela_moderna", Vector2i(14, 10)],
	# museu
	["estante", Vector2i(12, 26)], ["armario", Vector2i(16, 26)], ["armario", Vector2i(23, 26)],
	["estante", Vector2i(27, 26)], ["mesa_vela", Vector2i(20, 30)], ["lampiao", Vector2i(12, 32)],
	["mesa_vela", Vector2i(27, 32)], ["mesa_vela", Vector2i(12, 29)], ["quadro", Vector2i(14, 25)], ["janela", Vector2i(24, 25)],
	["tabela", Vector2i(11, 29)],
	# computador
	["servidor", Vector2i(2, 2)], ["bancada_moderna", Vector2i(6, 2)], ["estante_metal", Vector2i(10, 2)],
	["planta", Vector2i(2, 11)], ["caixas", Vector2i(11, 11)], ["luminaria", Vector2i(7, 11)], ["cabos", Vector2i(6, 7)],
	["tela_parede", Vector2i(4, 1)], ["janela_moderna", Vector2i(9, 1)], ["lousa", Vector2i(1, 7)],
	# materiais
	["estante_metal", Vector2i(27, 2)], ["bancada_moderna", Vector2i(31, 2)], ["armario_branco", Vector2i(36, 3)],
	["planta", Vector2i(36, 10)], ["caixas", Vector2i(28, 11)], ["luminaria", Vector2i(31, 11)],
	["tabela", Vector2i(29, 1)], ["lousa", Vector2i(34, 1)],
	# lixo eletrônico
	["barril", Vector2i(29, 26)], ["sucata", Vector2i(35, 26)], ["luminaria", Vector2i(31, 26)], ["lixeiras", Vector2i(29, 30)],
	["sucata", Vector2i(38, 30)], ["barril", Vector2i(38, 33)], ["barril", Vector2i(37, 33)],
	["caixas", Vector2i(29, 32)], ["cabos", Vector2i(34, 29)], ["janela_moderna", Vector2i(37, 25)],
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

	"terminal_quiz": {
		"nome": "Terminal do Quiz",
		"tipo": "quiz",
		"forma": "terminal",
		"cor": Color("7fe0ff"),
		"destaque": "?",
		"conta": false,
		"texto": "",
		"curiosidade": "",
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

	"minerio": {
		"nome": "Minério (bauxita)",
		"forma": "minerio",
		"cor": Color("b0583a"),
		"destaque": "Al",
		"texto": "Para fabricar aparelhos, primeiro é preciso tirar minerais da natureza, como a bauxita, de onde vem o alumínio (Al). A mineração pode desmatar, poluir rios e gastar muita energia. Reaproveitar os metais dos aparelhos velhos ajuda a natureza.",
		"curiosidade": "Reciclar alumínio gasta só cerca de 5% da energia que seria usada para fazer alumínio novo a partir do minério!",
	},

	# ---------- PEÇAS DO COMPUTADOR ----------
	"ssd": {
		"nome": "SSD",
		"forma": "ssd",
		"cor": Color("4a90d9"),
		"destaque": "Si",
		"texto": "O SSD guarda os arquivos em chips de memória feitos de silício, que prendem elétrons em \"gaiolinhas\" minúsculas. Ele não tem nenhuma peça que se mexe!\nElementos: silício (chips), cobre (trilhas), ouro (contatos) e estanho (solda).",
		"curiosidade": "Como não tem nada girando, o SSD é muito mais rápido que o HD e aguenta melhor uma queda.",
	},
	"hd": {
		"nome": "HD (disco rígido)",
		"forma": "hd",
		"cor": Color("b8c0cc"),
		"destaque": "Co",
		"texto": "O HD guarda os dados num disco que gira muito rápido. O disco é coberto por uma camada magnética de cobalto (Co) e platina (Pt), e uma agulha com um ímã de neodímio (Nd) magnetiza pedacinhos dessa camada.\nElementos: alumínio ou vidro (disco), cobalto e platina (camada magnética), neodímio (ímã) e cobre (motor).",
		"curiosidade": "A cabeça que lê os dados voa sobre o disco a uma distância milhares de vezes menor que a espessura de um fio de cabelo!",
	},
	"placa_video": {
		"nome": "Placa de vídeo",
		"forma": "gpu",
		"cor": Color("5ac87a"),
		"destaque": "Si",
		"texto": "A placa de vídeo desenha as imagens dos jogos e vídeos. O chip dela, de silício, tem bilhões de transistores, e ela esquenta tanto que precisa de um dissipador de metal e de ventoinhas.\nElementos: silício (chip), cobre e alumínio (dissipador), ouro (contatos), tântalo (capacitores) e estanho (solda).",
		"curiosidade": "O chip de uma placa de vídeo faz trilhões de contas por segundo para desenhar cada cena de um jogo!",
	},
	"memoria_ram": {
		"nome": "Memória RAM",
		"forma": "ram",
		"cor": Color("e05a5a"),
		"destaque": "Si Au",
		"texto": "A memória RAM guarda o que o computador está usando agora, como o jogo aberto. Ela é feita de chips de silício numa plaquinha, com contatos dourados na ponta.\nElementos: silício (chips), ouro (contatos), cobre (trilhas) e estanho (solda).",
		"curiosidade": "Quando o computador desliga, a RAM esquece tudo! Por isso é preciso salvar os arquivos no SSD ou no HD.",
	},

	# ---------- MATERIAIS ----------
	"fio_cobre": {
		"nome": "Fio de cobre",
		"forma": "fio",
		"cor": Color("d9824a"),
		"destaque": "Cu",
		"texto": "O cobre (Cu) conduz eletricidade muito bem. Ele está nos fios, nas trilhas das placas e até dentro dos chips, levando a corrente elétrica de um lugar para outro sem desperdiçar energia.",
		"curiosidade": "Um celular tem uns 15 gramas de cobre. É um dos metais que aparecem em maior quantidade dentro dele!",
	},
	"contato_ouro": {
		"nome": "Conector banhado a ouro",
		"forma": "conector",
		"cor": Color("e8c040"),
		"destaque": "Au",
		"texto": "O ouro (Au) quase não reage com o ar nem com a água, então não enferruja. Por isso os contatos dos chips e dos cabos ganham uma camadinha de ouro: a eletricidade sempre passa bem e com segurança.",
		"curiosidade": "Essa camada de ouro é mais fina do que um fio de cabelo, mas já basta para proteger o contato!",
	},
	"carcaca_aluminio": {
		"nome": "Notebook de alumínio",
		"forma": "notebook",
		"cor": Color("b8c0cc"),
		"destaque": "Al Mg",
		"texto": "Os aparelhos antigos tinham muito ferro, que é pesado. Hoje muitos notebooks e celulares usam alumínio (Al) e magnésio (Mg): metais leves, mas fortes, que deixam tudo mais fino e fácil de carregar.",
		"curiosidade": "O alumínio vem de um minério chamado bauxita, e o Brasil é um dos maiores produtores de bauxita do mundo!",
	},
	"vidro_tela": {
		"nome": "Vidro da tela",
		"forma": "vidro",
		"cor": Color("9fe0f0"),
		"destaque": "Si O",
		"texto": "O vidro é feito principalmente de sílica (dióxido de silício, a mesma substância da areia). O vidro dos celulares toma um banho químico de sal de potássio derretido: o potássio entra no vidro e deixa ele muito mais resistente a riscos e quedas.",
		"curiosidade": "Os aparelhos antigos usavam vidro grosso e pesado. O de hoje é bem mais fino e muito mais resistente!",
	},
	"plastico": {
		"nome": "Capinha de plástico",
		"forma": "plastico",
		"cor": Color("e05a8a"),
		"destaque": "C H",
		"texto": "Os plásticos são polímeros: moléculas gigantes feitas de carbono (C) e hidrogênio (H), que vêm principalmente do petróleo. Os plásticos de hoje são mais leves e resistentes que os antigos e protegem as peças de dentro do aparelho.",
		"curiosidade": "Um plástico pode levar centenas de anos para se desfazer na natureza. Por isso é tão importante reciclar!",
	},

	# ---------- MUSEU (ANTIGOS) ----------
	"tijolao": {
		"nome": "Celular tijolão (anos 1980)",
		"forma": "tijolao",
		"cor": Color("3a3a42"),
		"destaque": "Ni Cd",
		"texto": "Os primeiros celulares eram enormes e pesavam quase 1 kg! Tinham muito plástico comum e uma bateria pesada de níquel e cádmio (Ni e Cd), que durava pouco: dava para falar só uns 30 minutos.",
		"curiosidade": "Ele demorava umas 10 horas para carregar e só fazia ligações: nada de fotos, jogos ou internet!",
	},
	"radio": {
		"nome": "Rádio antigo",
		"forma": "radio",
		"cor": Color("c88a4a"),
		"destaque": "Pb S",
		"texto": "Os primeiros rádios, por volta de 1910, usavam um cristal chamado galena (sulfeto de chumbo, PbS) para captar o sinal, e funcionavam até sem pilha! Depois vieram os rádios de válvula, grandes e com caixa de madeira, que ficavam no meio da sala.",
		"curiosidade": "O cristal de galena foi um dos primeiros semicondutores usados na tecnologia: um \"avô\" do transistor!",
	},
	"telefone": {
		"nome": "Primeiro telefone (1876)",
		"forma": "telefone",
		"cor": Color("3a3a42"),
		"destaque": "C",
		"texto": "Em 1876, Alexander Graham Bell patenteou o telefone. Pouco depois, os telefones passaram a usar um microfone com grãozinhos de carvão (carbono, C): a voz apertava os grãos, a eletricidade passava mais ou menos, e o som viajava pelo fio de cobre.",
		"curiosidade": "Esse microfone de carvão foi usado nos telefones por quase 100 anos!",
	},
	"gabinete_ferro": {
		"nome": "Computador antigo",
		"forma": "gabinete",
		"cor": Color("d8cfb8"),
		"destaque": "Fe",
		"texto": "Os computadores antigos tinham caixas de ferro (aço) e peças enormes. Eram pesados, ocupavam a mesa inteira e eram muito mais lentos do que um celular de hoje.",
		"curiosidade": "Um celular de hoje é mais de mil vezes mais rápido do que um computador de mesa dos anos 1990!",
	},
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


## Perguntas do quiz: [pergunta, [opções], índice da certa, explicação].
const QUIZ := [
	["Qual material é o \"cérebro\" dos chips?", ["Ferro", "Silício", "Ouro"], 1,
		"O silício substituiu peças lentas e deixou os aparelhos rápidos e pequenos."],
	["Antigamente, os aparelhos eram...", ["Pesados e grandes", "Leves e finos", "Feitos de ouro puro"], 0,
		"Eles usavam muito ferro, vidro grosso e plástico comum."],
	["Onde devemos descartar um celular velho?", ["No lixo comum", "Enterrado no quintal", "Num ponto de coleta de lixo eletrônico"], 2,
		"Assim os materiais são reciclados e não poluem a natureza."],
	["Qual metal deixou as baterias leves e duradouras?", ["Lítio", "Chumbo", "Ferro"], 0,
		"As baterias de íon-lítio são leves e podem ser recarregadas muitas vezes."],
	["Por que os contatos dos chips são cobertos de ouro?", ["Para ficar bonito", "Porque o ouro não enferruja", "Porque o ouro é leve"], 1,
		"O ouro quase não reage, então o contato elétrico fica sempre bom."],
	["Qual metal leva a eletricidade pelos fios e circuitos?", ["Plástico", "Vidro", "Cobre"], 2,
		"O cobre conduz eletricidade muito bem."],
]


static func conta(id: String) -> bool:
	return COMPONENTES[id].get("conta", true)


static func total_componentes() -> int:
	var total := 0
	for item in OBJETOS:
		if conta(item[0]):
			total += 1
	return total
