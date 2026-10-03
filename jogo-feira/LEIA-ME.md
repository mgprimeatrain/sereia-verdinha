# Coelho Cientista e a Química na Tecnologia

Jogo para a feira de ciências, feito no **Godot 4.4**. O jogador anda pelas salas
de um laboratório e inspeciona componentes eletrônicos, aprendendo a química de cada um.

## Como abrir

1. Abra o Godot e clique em **Importar**.
2. Escolha o arquivo `project.godot` desta pasta (`jogo-feira`).
3. Clique em **Importar e Editar**.
4. Aperte **F5** (ou o botão ▶ no canto de cima) para jogar.

## Controles

| Tecla | O que faz |
|---|---|
| WASD ou setas | Andar |
| Shift (segurando) | Correr |
| Espaço | Pular |
| E ou Enter | Inspecionar / fechar a janela |
| F11 | Liga/desliga a tela cheia (o jogo já abre em tela cheia) |
| F2 | Recomeçar do zero (para o próximo visitante da feira) |

## O mapa

É um prédio só, visto na diagonal. O **Laboratório** fica no meio e tem
passagens para a **Energia** (esquerda), **Telas** (direita, e de lá para o
**Lixo Eletrônico**), **Processamento** (cima, e de lá para a **Sala dos
Materiais**) e **Museu** (baixo).

Na primeira vez em cada sala, o coelho explica o tema dela (frases do roteiro
da apresentação). No Laboratório tem o **Terminal do Quiz**, com as perguntas
do final da apresentação.

O mapa, os móveis, os objetos, as falas e as perguntas do quiz ficam em
`scripts/dados.gd`.

## O que cada sala mostra (roteiro da apresentação)

| Sala | Parte da apresentação | Objetos |
|---|---|---|
| Museu | Evolução dos materiais | pilha de Volta, válvula, TV de tubo, disquete, celular tijolão, computador antigo |
| Sala dos Materiais | Materiais e química | fio de cobre, conector de ouro, notebook de alumínio e magnésio, vidro da tela, plástico |
| Energia | Lítio | pilha alcalina, bateria de lítio, painel solar |
| Processamento | Silício | wafer, transistor, processador |
| Telas | Materiais especiais | LCD, OLED, tela touch |
| Lixo Eletrônico | Fabricação e impactos | minério (bauxita), placa velha, bateria estufada, pilhas usadas |
| Laboratório | Finalização e jogo | Terminal do Quiz |

## Sprites do coelho

Coloque na pasta `arte/` (**PNG com fundo transparente**) arquivos com o nome:

```
coelho_<ação>_<direção>_<colunas>x<linhas>.png
```

- **ação:** `parado`, `andando`, `correndo` ou `pulando` (a ação e a direção podem vir em qualquer ordem)
- **direção:** `frente` (andando para baixo), `costas` (para cima) ou `lado`
  (desenhe virado para a **direita**; o jogo espelha para a esquerda)
- **colunas x linhas:** quantos quadros a folha tem. Todos os quadros precisam
  ter o mesmo tamanho. Se for uma imagem só, pode deixar sem: `coelho_parado_frente.png`

Exemplos:

| Arquivo | O que é |
|---|---|
| `coelho_parado_frente.png` | parado, de frente (1 imagem) |
| `coelho_andando_frente_8x3.png` | andando de frente, 24 quadros em 8 colunas e 3 linhas |
| `coelho_andando_costas_8x3.png` | andando de costas |
| `coelho_correndo_lado_7x3.png` | correndo de lado |
| `coelho_pulando_lado_12x2.png` | pulando de lado |

Pode colocar só algumas: o que faltar é trocado pela imagem mais parecida que
existir (por exemplo, sem "correndo de frente" ele usa "andando de frente").

O jogo arruma as imagens sozinho quando abre: apaga o fundo branco de fora do
contorno preto, alinha os quadros pelos pés e pela cabeça (para o coelho não
tremer) e deixa o coelho sempre do mesmo tamanho. Para mudar o tamanho do
coelho, mude `ALTURA_COELHO` no começo de `scripts/jogador.gd`.
Sem nenhuma imagem, o jogo usa o coelho desenhado por código.

**Rostinho do coelho:** coloque `arte/coelho_rosto.png` e ele aparece na caixa
de fala.

## Imagens dos componentes

O jogo funciona sem imagens, usando desenhos provisórios. Para trocar,
coloque um **PNG com fundo transparente** com o nome certo:

| Arquivo | O que é |
|---|---|
| `arte/componentes/pilha_alcalina.png` | Pilha alcalina |
| `arte/componentes/bateria_litio.png` | Bateria de íon-lítio |
| `arte/componentes/painel_solar.png` | Painel solar |
| `arte/componentes/wafer.png` | Wafer de silício |
| `arte/componentes/transistor.png` | Transistor |
| `arte/componentes/processador.png` | Processador |
| `arte/componentes/tela_lcd.png` | Tela LCD |
| `arte/componentes/tela_oled.png` | Tela OLED |
| `arte/componentes/tela_touch.png` | Tela touch |
| `arte/componentes/placa_velha.png` | Placa de circuito velha |
| `arte/componentes/bateria_inchada.png` | Bateria estufada |
| `arte/componentes/pilhas_usadas.png` | Pilhas usadas |
| `arte/componentes/pilha_volta.png` | Pilha de Volta |
| `arte/componentes/valvula.png` | Válvula |
| `arte/componentes/tv_tubo.png` | TV de tubo |
| `arte/componentes/disquete.png` | Disquete |
| `arte/componentes/boas_vindas.png` | Placa de boas-vindas |
| `arte/componentes/fio_cobre.png` | Fio de cobre |
| `arte/componentes/contato_ouro.png` | Conector banhado a ouro |
| `arte/componentes/carcaca_aluminio.png` | Notebook de alumínio |
| `arte/componentes/vidro_tela.png` | Vidro da tela |
| `arte/componentes/plastico.png` | Capinha de plástico |
| `arte/componentes/tijolao.png` | Celular tijolão |
| `arte/componentes/gabinete_ferro.png` | Computador antigo |
| `arte/componentes/minerio.png` | Minério (bauxita) |
| `arte/componentes/terminal_quiz.png` | Terminal do quiz |

Depois de colocar os arquivos, volte para o Godot (ele importa sozinho) e aperte F5.

## Como mudar textos ou adicionar componentes

Tudo fica em `scripts/dados.gd`: os textos, as cores, as salas e onde cada objeto fica.

## Arquivos

- `scripts/main.gd`: controla o jogo (título, troca de sala, inspeção, coleção)
- `scripts/mapa.gd`: monta o mapa inteiro (chão, paredes, móveis, objetos)
- `scripts/parede.gd`: os blocos de parede (ficam transparentes quando tampam o coelho)
- `scripts/jogador.gd`: o coelho e a câmera que segue ele
- `scripts/recorte.gd`: arruma os sprites do coelho (fundo branco, alinhamento, tamanho)
- `scripts/objeto.gd`: os componentes que dá para inspecionar
- `scripts/escuridao.gd`: a escuridão e a luz da lanterna
- `scripts/interface.gd`: tela de título, HUD e janela de inspeção
- `scripts/fala.gd`: a caixinha de fala do coelho
- `scripts/quiz.gd`: o quiz do final
- `scripts/desenhos.gd`: os desenhos provisórios (as cores do coelho ficam no começo da parte do coelho)
- `scripts/movel.gd`: os móveis de decoração (estantes, bancadas, velas...)
