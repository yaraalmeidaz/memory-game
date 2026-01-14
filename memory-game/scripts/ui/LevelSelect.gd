extends Control

const LOCK_TEX := preload("res://assets/imagens/lock_closed.png")

@onready var player_label: Label = $VBox/Player
@onready var total_label: Label = $VBox/Total
@onready var level_buttons: Array[Button] = [
	$VBox/Scroll/Grid/Level1,
	$VBox/Scroll/Grid/Level2,
	$VBox/Scroll/Grid/Level3,
	$VBox/Scroll/Grid/Level4,
	$VBox/Scroll/Grid/Level5,
	$VBox/Scroll/Grid/Level6,
]

var _lock_tex_small: Texture2D

func _ready() -> void:
	player_label.text = "Jogador: %s" % GameState.player_name
	_lock_tex_small = _make_small_icon(LOCK_TEX, 28)
	_bind_buttons()
	_update_buttons()
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

func _bind_buttons() -> void:
	# Conecta uma vez (evita duplicar conexão se a cena recarregar).
	for i in range(level_buttons.size()):
		var btn := level_buttons[i]
		if btn == null:
			continue
		if btn.pressed.is_connected(_on_level_pressed.bind(i)):
			continue
		btn.pressed.connect(_on_level_pressed.bind(i))


func _update_buttons() -> void:
	var max_levels := min(GameState.LEVEL_PAIRS.size(), level_buttons.size())
	for i in range(level_buttons.size()):
		var btn := level_buttons[i]
		if btn == null:
			continue
		var visible := i < max_levels
		btn.visible = visible
		if not visible:
			continue

		var pairs := GameState.get_pairs_for_level(i)
		var time_txt := ""
		if i < GameState.level_times.size() and GameState.level_times[i] >= 0:
			time_txt = " — %s" % GameState.format_time(GameState.level_times[i])
		var locked := i > GameState.unlocked_level
		if locked:
			btn.text = "Nível %d — bloqueado" % [i + 1]
			btn.icon = _lock_tex_small
			btn.expand_icon = false
		else:
			btn.text = "Nível %d — %d pares%s" % [i + 1, pairs, time_txt]
			btn.icon = null
		btn.disabled = locked


func _on_level_pressed(level_index: int) -> void:
	GameState.current_level = level_index
	get_tree().change_scene_to_file("res://scenes/levels/Level%d.tscn" % (level_index + 1))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
