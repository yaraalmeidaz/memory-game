extends Control

const CARD_SCENE := preload("res://scenes/Card.tscn")
const PERSONAGENS_DIR := "res://assets/imagens/Personagens"

@onready var info_label: Label = $TopBar/Info
@onready var timer_label: Label = $TopBar/Timer
@onready var board: Node2D = $Board
@onready var overlay: ColorRect = $Overlay
@onready var overlay_label: Label = $Overlay/OverlayLabel

var _start_msec: int = 0
var _blocked := false
var _first: Card
var _second: Card

var _total_cards := 0
var _matched_cards := 0

func _ready() -> void:
	overlay.visible = false
	_start_msec = Time.get_ticks_msec()
	_first = null
	_second = null
	_blocked = false
	_matched_cards = 0

	var level := GameState.current_level
	var pairs := GameState.get_pairs_for_level(level)
	info_label.text = "Jogador: %s  |  Nível %d (%d pares)" % [GameState.player_name, level + 1, pairs]

	_build_board(pairs)

func _process(_delta: float) -> void:
	var elapsed := float(Time.get_ticks_msec() - _start_msec) / 1000.0
	timer_label.text = GameState.format_time(elapsed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")

func _build_board(pairs: int) -> void:
	for child in board.get_children():
		child.queue_free()

	var available := _list_personagens()
	available.shuffle()
	if available.size() < pairs:
		push_error("Poucos personagens: precisa %d, tem %d" % [pairs, available.size()])
		pairs = min(pairs, available.size())

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
	var top_reserved: float = 80.0
	var area_w: float = vp.x
	var area_h: float = vp.y - top_reserved
	var columns: int = int(ceil(sqrt(float(deck.size()))))
	var rows: int = int(ceil(float(deck.size()) / float(columns)))

	var base_size: Vector2 = Vector2(725.0, 1102.0)
	var gap: float = 10.0
	var scale_x: float = (area_w - gap * float(columns - 1)) / (base_size.x * float(columns))
	var scale_y: float = (area_h - gap * float(rows - 1)) / (base_size.y * float(rows))
	var s: float = clampf(minf(scale_x, scale_y), 0.06, 0.22)

	var card_w: float = base_size.x * s
	var card_h: float = base_size.y * s
	var grid_w: float = float(columns) * card_w + float(columns - 1) * gap
	var grid_h: float = float(rows) * card_h + float(rows - 1) * gap
	var origin: Vector2 = Vector2((vp.x - grid_w) * 0.5, top_reserved + (area_h - grid_h) * 0.5)

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

	overlay.visible = true
	overlay_label.text = "Concluído! Tempo: %s" % GameState.format_time(elapsed)
	await get_tree().create_timer(1.0).timeout

	if level >= GameState.LEVEL_PAIRS.size() - 1:
		GameState.submit_run_to_leaderboard()
		get_tree().change_scene_to_file("res://scenes/Leaderboard.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")

func _list_personagens() -> Array[String]:
	var names: Array[String] = []
	var dir := DirAccess.open(PERSONAGENS_DIR)
	if dir == null:
		push_error("Não abriu pasta: " + PERSONAGENS_DIR)
		return names

	for f in dir.get_files():
		if f.get_extension().to_lower() != "png":
			continue
		if f.ends_with(".import"):
			continue
		names.append(f.get_basename())
	return names
