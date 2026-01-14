extends Control

const LOCK_TEX := preload("res://assets/imagens/lock_closed.png")

@onready var player_label: Label = $VBox/Player
@onready var total_label: Label = $VBox/Total
@onready var grid: GridContainer = $VBox/Scroll/Grid

var _lock_tex_small: Texture2D

func _ready() -> void:
	player_label.text = "Jogador: %s" % GameState.player_name
	_lock_tex_small = _make_small_icon(LOCK_TEX, 28)
	_build_buttons()
	_update_total_time()


func _make_small_icon(tex: Texture2D, size_px: int) -> Texture2D:
	if tex == null:
		return tex
	var img := tex.get_image()
	if img == null:
		return tex
	img.resize(size_px, size_px, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)


func _update_total_time() -> void:
	var total := 0.0
	var any := false
	for t in GameState.level_times:
		if t >= 0:
			total += t
			any = true
	if any:
		total_label.text = "Tempo total (até agora): %s" % GameState.format_time(total)
	else:
		total_label.text = "Tempo total (até agora): --:--"

func _build_buttons() -> void:
	for child in grid.get_children():
		child.queue_free()

	for i in GameState.LEVEL_PAIRS.size():
		var pairs := GameState.get_pairs_for_level(i)
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 46)
		var time_txt := ""
		if GameState.level_times[i] >= 0:
			time_txt = " — %s" % GameState.format_time(GameState.level_times[i])
		var locked := i > GameState.unlocked_level
		if locked:
			btn.text = "Nível %d — bloqueado" % [i + 1]
			btn.icon = _lock_tex_small
			btn.expand_icon = false
		else:
			btn.text = "Nível %d — %d pares%s" % [i + 1, pairs, time_txt]
		btn.disabled = locked
		btn.pressed.connect(func():
			GameState.current_level = i
			get_tree().change_scene_to_file("res://scenes/levels/Level%d.tscn" % (i + 1)))
		grid.add_child(btn)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
