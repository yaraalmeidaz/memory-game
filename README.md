# Memory Game (Godot)

Jogo da memória feito em **Godot 4.5** (GDScript), com níveis progressivos e ranking (Top 5) baseado no **tempo total** da campanha.

## Visão geral

O objetivo é encontrar pares de cartas iguais. Cada fase tem uma quantidade fixa de pares e o layout do tabuleiro se ajusta automaticamente ao tamanho da janela.

**Principais funcionalidades**

- 6 níveis com dificuldade progressiva (quantidade de pares por fase).
- Tabuleiro responsivo: calcula colunas/linhas e escala das cartas para caber na tela.
- Sistema de desbloqueio de níveis.
- Ranking **Top 5** persistido localmente (arquivo `user://leaderboard.cfg`).

## Como rodar

### Pelo editor (recomendado)

1. Abra o Godot.
2. Clique em **Importar** e selecione a pasta `memory-game/` (onde está o `project.godot`).
3. Abra o projeto e clique em **Play**.

### Configuração de janela

O projeto usa `canvas_items` para o stretch e define um tamanho base em `project.godot`.

## Lógica do jogo (como funciona)

### Baralho e pares

- Cada nível define a quantidade de pares.
- O jogo lista as imagens em `res://assets/imagens/Personagens/` e seleciona aleatoriamente a quantidade necessária.
- O deck é duplicado (2x cada personagem) e embaralhado.

### Interação (virar cartas)

- Clique em uma carta para revelar.
- Se duas cartas reveladas forem diferentes, elas voltam para baixo após um pequeno tempo.
- Se forem iguais, ficam viradas para cima até o final da fase.

### Layout do tabuleiro

O tabuleiro é calculado em runtime com base no viewport:

- Escolha de colunas (prioriza cartas maiores e, quando possível, linhas completas).
- Cálculo de escala das cartas para preencher a área útil da tela.
- Posicionamento centralizado com margens e espaçamento adaptativo.

### Progresso, níveis e estado global

O estado global fica no autoload `GameState`:

- `current_level`: nível atual.
- `unlocked_level`: maior nível desbloqueado.
- `level_times`: tempo por nível.

Ao concluir um nível, o próximo é desbloqueado. Ao finalizar todos os níveis, o run é submetido para o ranking.

## Ranking (Top 5)

- O ranking considera o **tempo total** da campanha.
- Os dados são persistidos localmente em `user://leaderboard.cfg`.
- A tela exibe uma tabela com 3 colunas: **Rank / Nome / Tempo**.

## Estrutura do projeto

Pastas mais importantes:

- `memory-game/scenes/` — cenas do jogo (UI, níveis, cartas, ranking).
- `memory-game/scripts/` — scripts em GDScript.
	- `scripts/ui/GameScene.gd` — lógica principal do gameplay (tabuleiro, clique, match, fim de fase).
	- `scripts/autoload/GameState.gd` — estado global + persistência do ranking.
	- `scripts/ui/Leaderboard.gd` — renderização do Top 5.
- `memory-game/assets/` — imagens e fontes.

## Exportar (gerar executável)

1. No Godot: **Projeto → Exportar**.
2. Crie/seleciona um preset (Linux/Windows/Web).
3. Defina o caminho do arquivo de saída.
4. Clique em **Exportar Projeto**.

## Notas

- Este repositório inclui assets (imagens) usados pela interface e pelo jogo. Garanta que você tem permissão para distribuir/reutilizar os assets do projeto.
- Se algo “sumir” na UI após editar cenas, a recomendação é manter scripts tolerantes a nós opcionais (ex.: `get_node_or_null`).