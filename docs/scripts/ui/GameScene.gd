extends Control

const CARD_SCENE := preload("res://scenes/game/Card.tscn")
const PERSONAGENS_DIR := "res://assets/imagens/Personagens"

const _KNOWN_PERSONAGENS: Array[String] = [
	"dwightschrute",
	"eren",
	"hange",
	"homemaranha",
	"iguro",
	"killua",
	"kurapika",
	"mikasa",
	"neferpitou",
	"nezuco",
	"rick",
	"tengen",
]

@onready var info_label := get_node_or_null("TopBar/Info") as Label
@onready var timer_label := get_node_or_null("TopBar/Timer") as Label
@onready var board := get_node_or_null("Board") as Node2D
@onready var overlay := get_node_or_null("Overlay") as ColorRect
@onready var overlay_label := get_node_or_null("Overlay/OverlayLabel") as Label

var _start_msec: int = 0
var _blocked := false
var _first: Card
var _second: Card

var _total_cards := 0
var _matched_cards := 0

const _PREFERRED_COLUMNS: Array[int] = [6, 5, 4, 3, 2]
const _MARGIN_X: float = 16.0
const _MARGIN_Y: float = 12.0
const _CARD_BASE_SIZE: Vector2 = Vector2(421, 593)


func _ready() -> void:
	if overlay != null:
		overlay.visible = false
	_start_msec = Time.get_ticks_msec()
	_first = null
	_second = null
	_blocked = false
	_matched_cards = 0

	var level := GameState.current_level
	var pairs := GameState.get_pairs_for_level(level)
	# UI opcional: se existir um label de info, deixa vazio (sem nome do jogador).
	if info_label != null:
		info_label.text = ""

	# Monta o tabuleiro depois que o layout inicial (TopBar/anchors) foi calculado,
	# senão o TopBar pode reportar um tamanho gigante e empurrar as cartas pra fora.
	call_deferred("_build_board", pairs)


func _input(event: InputEvent) -> void:
	# Clique nas cartas via scene-level picking (mais confiável no Godot 4.5)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if overlay.visible:
			return
		# Se o mouse está sobre a UI (ex.: botão Voltar), deixa a UI lidar.
		# Importante: o Control raiz pode aparecer como hovered; isso não deve bloquear o tabuleiro.
		var hovered := get_viewport().gui_get_hovered_control()
		if hovered != null and hovered != self:
			if $TopBar.is_ancestor_of(hovered):
				return

		var picked := _pick_card_at(get_global_mouse_position())
		if picked != null:
			get_viewport().set_input_as_handled()
			_on_card_pressed(picked)


func _pick_card_at(mouse_global: Vector2) -> Card:
	var children := board.get_children()
	for idx in range(children.size() - 1, -1, -1):
		var n := children[idx]
		if n is Card:
			var c: Card = n
			var local := c.to_local(mouse_global)
			var rect := Rect2(-_CARD_BASE_SIZE * 0.5, _CARD_BASE_SIZE)
			if rect.has_point(local):
				return c
	return null

func _process(_delta: float) -> void:
	var elapsed := float(Time.get_ticks_msec() - _start_msec) / 1000.0
	if timer_label != null:
		timer_label.text = GameState.format_time(elapsed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _build_board(pairs: int) -> void:
	if board == null:
		push_error("Board não encontrado na cena Game")
		return
	for child in board.get_children():
		child.queue_free()

	var available := _list_personagens()
	available.shuffle()
	if available.size() < pairs:
		push_error("Poucos personagens: precisa %d, tem %d" % [pairs, available.size()])
		pairs = min(pairs, available.size())
	if pairs <= 0:
		push_error("Sem personagens disponíveis para montar o tabuleiro (export Web pode não listar arquivos por diretório).")
		return

	var chosen: Array[String] = []
	chosen.assign(available.slice(0, pairs))

	var deck: Array[String] = []
	for name in chosen:
		deck.append(name)
		deck.append(name)
	deck.shuffle()

	_total_cards = deck.size()

	# layout
	var vp: Vector2 = get_viewport_rect().size
	# Em alguns layouts o TopBar pode iniciar com size.y muito grande antes do layout estabilizar.
	# Limitamos para manter o tabuleiro visível.
	var top_bar_h: float = clampf($TopBar.size.y, 0.0, 120.0)
	var top_reserved: float = maxf(70.0, top_bar_h + 10.0)
	var area_w: float = vp.x
	var area_h: float = vp.y - top_reserved
	# gap adaptativo: mantém “respiro” mas usa bem a tela
	var gap: float = clampf(minf(vp.x, vp.y) * 0.010, 4.0, 12.0)
	var columns: int = _choose_columns(deck.size(), vp, top_reserved, gap)
	var rows: int = int(ceil(float(deck.size()) / float(columns)))

	var base_size: Vector2 = _CARD_BASE_SIZE

	var usable_w: float = maxf(1.0, area_w - 2.0 * _MARGIN_X - gap * float(columns - 1))
	var usable_h: float = maxf(1.0, area_h - 2.0 * _MARGIN_Y - gap * float(rows - 1))

	var scale_x: float = usable_w / (base_size.x * float(columns))
	var scale_y: float = usable_h / (base_size.y * float(rows))
	var s: float = clampf(minf(scale_x, scale_y), 0.06, 0.65)

	var card_w: float = base_size.x * s
	var card_h: float = base_size.y * s
	var grid_w: float = float(columns) * card_w + float(columns - 1) * gap
	var grid_h: float = float(rows) * card_h + float(rows - 1) * gap
	var origin: Vector2 = Vector2(
		_MARGIN_X + (area_w - 2.0 * _MARGIN_X - grid_w) * 0.5,
		top_reserved + _MARGIN_Y + (area_h - 2.0 * _MARGIN_Y - grid_h) * 0.5
	)

	for i in deck.size():
		var card := CARD_SCENE.instantiate() as Card
		card.personagem = deck[i]
		card.scale = Vector2.ONE * s
		card.pressed.connect(_on_card_pressed)
		board.add_child(card)

		var col: int = i % columns
		var row: int = int(i / columns)
		var x: float = origin.x + float(col) * (card_w + gap) + card_w * 0.5
		var y: float = origin.y + float(row) * (card_h + gap) + card_h * 0.5
		card.position = Vector2(x, y)


func _choose_columns(card_count: int, vp: Vector2, top_reserved: float, gap: float) -> int:
	# Escolhe o número de colunas que maximiza o tamanho das cartas (usa mais a largura).
	# Regra principal: tentar manter a mesma quantidade de cartas por linha, evitando
	# última linha incompleta (ou seja, preferir grids sem sobras) quando possível.
	var area_w: float = vp.x
	var area_h: float = vp.y - top_reserved
	var base_size: Vector2 = _CARD_BASE_SIZE

	var candidates_no_remainder: Array[int] = []
	for c in _PREFERRED_COLUMNS:
		if c > 0 and card_count % c == 0:
			candidates_no_remainder.append(c)
	# Se não houver nenhum divisor dentro dos preferidos, tenta outros divisores (limitados)
	# para ainda conseguir um grid completo sem explodir o número de colunas.
	if candidates_no_remainder.is_empty():
		var max_c: int = min(card_count, 8)
		for c in range(2, max_c + 1):
			if card_count % c == 0 and not _PREFERRED_COLUMNS.has(c):
				candidates_no_remainder.append(c)

	var candidates: Array[int]
	var enforce_full_rows := false
	if not candidates_no_remainder.is_empty():
		candidates = candidates_no_remainder
		enforce_full_rows = true
	else:
		candidates = _PREFERRED_COLUMNS

	var best_c: int = candidates[0] if candidates.size() > 0 else 4
	var best_score: float = -999999.0

	for c in candidates:
		if c <= 0:
			continue
		var rows: int = int(ceil(float(card_count) / float(c)))
		var empty: int = rows * c - card_count

		var usable_w: float = maxf(1.0, area_w - 2.0 * _MARGIN_X - gap * float(c - 1))
		var usable_h: float = maxf(1.0, area_h - 2.0 * _MARGIN_Y - gap * float(rows - 1))
		var scale_x: float = usable_w / (base_size.x * float(c))
		var scale_y: float = usable_h / (base_size.y * float(rows))
		var raw_s: float = minf(scale_x, scale_y)

		var score: float = raw_s
		if not enforce_full_rows:
			# Quando não dá para evitar sobras, penaliza buracos (prioridade ainda é carta maior).
			score -= float(empty) * 0.003
			# Leve bônus quando não há buracos.
			if empty == 0:
				score += 0.002

		if score > best_score:
			best_score = score
			best_c = c

	return best_c

func _on_card_pressed(card: Card) -> void:
	if _blocked:
		return
	if card.matched:
		return

	# evita clicar duas vezes na mesma
	if _first == card:
		return
	if _second == card:
		return

	card.reveal()

	if _first == null:
		_first = card
		return

	if _second == null:
		_second = card
		_check_pair()

func _check_pair() -> void:
	if _first == null or _second == null:
		return

	_blocked = true

	if _first.personagem == _second.personagem:
		_first.matched = true
		_second.matched = true
		_matched_cards += 2
		_first = null
		_second = null
		_blocked = false
		if _matched_cards >= _total_cards:
			_finish_level()
		return

	await get_tree().create_timer(0.85).timeout
	if _first:
		_first.conceal()
	if _second:
		_second.conceal()
	_first = null
	_second = null
	_blocked = false

func _finish_level() -> void:
	var elapsed := float(Time.get_ticks_msec() - _start_msec) / 1000.0
	var level := GameState.current_level
	GameState.complete_level(level, elapsed)
	_blocked = true

	if overlay != null:
		overlay.visible = true
	# Tela de conclusão: apenas imagem (sem texto).
	if overlay_label != null:
		overlay_label.text = ""
	await get_tree().create_timer(1.0).timeout

	if level >= GameState.LEVEL_PAIRS.size() - 1:
		GameState.submit_run_to_leaderboard()
		get_tree().change_scene_to_file("res://scenes/ranking/Leaderboard.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _list_personagens() -> Array[String]:
	var names: Array[String] = []
	var dir := DirAccess.open(PERSONAGENS_DIR)
	if dir != null:
		for f in dir.get_files():
			if f.ends_with(".import"):
				continue
			if f.get_extension().to_lower() != "png":
				continue
			names.append(f.get_basename())

	# Em builds exportadas (especialmente Web), o diretório pode não listar os arquivos fonte
	# (ex.: só o recurso importado vai no PCK). Nesse caso, usa lista fallback.
	if names.is_empty():
		for base in _KNOWN_PERSONAGENS:
			var p := "%s/%s.png" % [PERSONAGENS_DIR, base]
			if ResourceLoader.exists(p):
				names.append(base)

	if names.is_empty():
		push_error("Não foi possível obter lista de personagens em: " + PERSONAGENS_DIR)

	return names
