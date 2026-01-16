# Memory Game — Godot 4 (Web)

Jogo da memória 2D desenvolvido com **Godot Engine 4**, com foco em arquitetura de cenas, controle de estado de jogo, persistência de dados e publicação Web.  
O projeto foi exportado para **HTML5** e disponibilizado publicamente via **GitHub Pages**.

🔗 **Demo online:**  
https://yaraalmeidaz.github.io/memory-game/

---

## Visão Geral

O **Memory Game** é um jogo de lógica baseado em correspondência de pares, estruturado em múltiplos níveis com progressão controlada.  
Cada fase é cronometrada e o desempenho do jogador é registrado localmente, permitindo a construção de um ranking persistente entre sessões.

O projeto foi concebido com atenção à organização do código, reutilização de cenas, separação de responsabilidades e compatibilidade com execução em navegador.

---

## Funcionalidades

- Seleção e progressão por níveis
- Sistema de desbloqueio baseado no desempenho do jogador
- Controle de tempo por fase
- Registro e exibição de ranking (Top 5)
- Persistência de dados local utilizando o sistema `user://` do Godot
- Exportação Web (HTML5) configurada para GitHub Pages

---

## Tecnologias

- **Godot Engine 4.5**
- **GDScript**
- **Exportação Web (HTML5)**

---


## Estrutura do projeto

> Importante: o projeto do Godot está na pasta `docs/`.

- `docs/project.godot`: arquivo do projeto
- `docs/scenes/`: cenas (`.tscn`)
- `docs/scripts/`: scripts (`.gd`)
- `docs/assets/`: imagens, fontes e outros recursos
- `docs/index.html`, `docs/index.js`, `docs/index.wasm`, `docs/index.pck`: build/export web (gerado pelo Godot)

## Como abrir e rodar localmente

### Abrir no editor (Godot)

No Linux, pelo terminal:

```bash
# Se seu binário for Godot 4
godot4 -e --path ~/Jogo/memory-game/docs

# Ou, se o comando for "godot"
godot -e --path ~/Jogo/memory-game/docs
```

### Rodar o jogo

```bash
godot4 --path ~/Jogo/memory-game/docs
```

## Exportar para Web

1. Abra o projeto (pasta `docs/`).
2. No Godot: **Project → Export…**
3. Se não existir, adicione o preset **Web**.
4. Instale os **Export Templates** (se o Godot pedir).
5. No preset Web, escolha o **Caminho de Exportação** como `./index.html`.
6. Clique em **Export Project**.

Isso atualiza os arquivos de export dentro de `docs/`.

## Publicar no GitHub Pages

1. Suba o export para o repositório:

```bash
cd ~/Jogo/memory-game
git add docs/
git commit -m "Atualiza export web"
git push
```

2. No GitHub: **Settings → Pages**
	- Source: *Deploy from a branch*
	- Branch: `main`
	- Folder: `/docs`

3. Aguarde a publicação e acesse:
	- https://yaraalmeidaz.github.io/memory-game/

## Autoria

Projeto **autoral**, desenvolvido por **Yara Almeida**, aluna do **IFSP — Campus Araraquara**.  

O desenvolvimento ocorreu ao longo da última semana, aplicando na prática os conceitos e técnicas aprendidos no curso  
**“Crie Jogos 2D com Godot 4 e GDScript + Start Game Design”**, com foco em lógica de jogos, estruturação de projetos, controle de estados e experiência do usuário.

