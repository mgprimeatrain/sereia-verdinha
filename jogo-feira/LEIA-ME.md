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
| F11 | Tela cheia |
| F2 | Recomeçar do zero (para o próximo visitante da feira) |

## O mapa

É um prédio só, visto na diagonal. O **Laboratório** fica no meio e tem
passagens para a **Energia** (esquerda), **Telas** (direita, e de lá para o
**Lixo Eletrônico**), **Processamento** (cima) e **Museu** (baixo).
O mapa, os móveis e os objetos ficam em `scripts/dados.gd`.

## Sprites do coelho

Coloque na pasta `arte/` (PNG com **fundo transparente**, todos os quadros do
mesmo tamanho, em grade, com o coelho virado para a **direita**):

| Arquivo | Animação | Grade esperada |
|---|---|---|
| `arte/coelho_andando.png` | andando (o 1º quadro é usado parado) | 8 colunas × 3 linhas |
| `arte/coelho_correndo.png` | correndo | 7 colunas × 3 linhas |
| `arte/coelho_pulando.png` | pulando | 12 colunas × 2 linhas |

Se a grade da sua imagem for diferente, mude `colunas` e `linhas` no começo de
`scripts/jogador.gd`. Sem essas imagens, o jogo usa o coelho desenhado por código.

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

Depois de colocar os arquivos, volte para o Godot (ele importa sozinho) e aperte F5.

## Como mudar textos ou adicionar componentes

Tudo fica em `scripts/dados.gd`: os textos, as cores, as salas e onde cada objeto fica.

## Arquivos

- `scripts/main.gd`: controla o jogo (título, troca de sala, inspeção, coleção)
- `scripts/mapa.gd`: monta o mapa inteiro (chão, paredes, móveis, objetos)
- `scripts/parede.gd`: os blocos de parede (ficam transparentes quando tampam o coelho)
- `scripts/jogador.gd`: o coelho e a câmera que segue ele
- `scripts/objeto.gd`: os componentes que dá para inspecionar
- `scripts/escuridao.gd`: a escuridão e a luz da lanterna
- `scripts/interface.gd`: tela de título, HUD e janela de inspeção
- `scripts/desenhos.gd`: os desenhos provisórios (as cores do coelho ficam no começo da parte do coelho)
- `scripts/movel.gd`: os móveis de decoração (estantes, bancadas, velas...)
