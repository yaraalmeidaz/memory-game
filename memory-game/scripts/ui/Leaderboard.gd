extends Control

@onready var your_time := get_node_or_null("VBox/YourTime") as Label
@onready var list_box := get_node_or_null("VBox/List") as GridContainer

const _BLACK := Color(0, 0, 0, 1)

func _make_cell(text_value: String, align: int) -> Label:
	var lbl := Label.new()
	lbl.text = text_value
	lbl.horizontal_alignment = align
	lbl.add_theme_color_override("font_color", _BLACK)
	return lbl

func _clear_rows_keep_header() -> void:
	if list_box == null:
		return
	# Mantém os 3 primeiros filhos como header (Rank/Nome/Tempo).
	var children := list_box.get_children()
	for i in range(children.size() - 1, -1, -1):
		if i >= 3:
			children[i].queue_free()

func _ready() -> void:
	var total := GameState.get_total_time()
	# Você pediu sem nome do jogador; aqui é só o tempo (se esse label existir).
	if your_time != null:
		your_time.text = "Tempo: %s" % GameState.format_time(total)

	if list_box == null:
		push_error("Leaderboard: nó VBox/List não encontrado")
		return

	# Garante 3 colunas (Rank/Nome/Tempo)
	list_box.columns = 3
	_clear_rows_keep_header()

	var top := GameState.get_top5()
	if top.is_empty():
		list_box.add_child(_make_cell("-", HORIZONTAL_ALIGNMENT_CENTER))
		list_box.add_child(_make_cell("(Sem resultados ainda)", HORIZONTAL_ALIGNMENT_LEFT))
		list_box.add_child(_make_cell("-", HORIZONTAL_ALIGNMENT_RIGHT))
		return

	for i in top.size():
		var e: Dictionary = top[i]
		list_box.add_child(_make_cell(str(i + 1), HORIZONTAL_ALIGNMENT_CENTER))
		list_box.add_child(_make_cell(str(e["name"]), HORIZONTAL_ALIGNMENT_LEFT))
		list_box.add_child(_make_cell(GameState.format_time(float(e["time"])), HORIZONTAL_ALIGNMENT_RIGHT))

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
