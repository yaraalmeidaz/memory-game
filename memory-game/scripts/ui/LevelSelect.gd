extends Control

const LOCK_TEX := preload("res://assets/imagens/lock_closed.png")
const LEVELSELECT_LOCK_PATH := "res://assets/imagens/LevelSelect/bloqueado.png"
const LEVELSELECT_UNLOCK_PATH := "res://assets/imagens/LevelSelect/desbloqueado.png"

@onready var player_label := get_node_or_null("VBox/Player") as Label
@onready var total_label := get_node_or_null("VBox/Total") as Label
@onready var level_buttons: Array[Button] = _collect_level_buttons()

var _lock_tex_small: Texture2D
var _icon_locked: Texture2D
var _icon_unlocked: Texture2D

var _empty_style := StyleBoxEmpty.new()

func _ready() -> void:
	if player_label != null:
		player_label.text = "Jogador: %s" % GameState.player_name
	# Se os assets do LevelSelect existirem, usa eles. Caso contrário, cai no lock padrão.
	if ResourceLoader.exists(LEVELSELECT_LOCK_PATH):
		_icon_locked = load(LEVELSELECT_LOCK_PATH)
	if ResourceLoader.exists(LEVELSELECT_UNLOCK_PATH):
		_icon_unlocked = load(LEVELSELECT_UNLOCK_PATH)

	# Tamanho do ícone baseado no botão (pra virar "imagem" do botão)
	var icon_size_px: int = 46
	if level_buttons.size() > 0 and level_buttons[0] != null:
		var s := level_buttons[0].custom_minimum_size
		if s.x > 0 and s.y > 0:
			icon_size_px = int(minf(s.x, s.y))

	_lock_tex_small = _make_small_icon(LOCK_TEX, icon_size_px)
	if _icon_locked != null:
		_icon_locked = _make_small_icon(_icon_locked, icon_size_px)
	if _icon_unlocked != null:
		_icon_unlocked = _make_small_icon(_icon_unlocked, icon_size_px)
	_bind_buttons()
	_update_buttons()
	_update_total_time()


func _collect_level_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	var grid := $VBox/Scroll/Grid
	for child in grid.get_children():
		if child is Button:
			buttons.append(child)
	# Ordena por nome (Level1, Level2, ...) para manter o índice certo.
	buttons.sort_custom(func(a: Button, b: Button) -> bool:
		return a.name.naturalnocasecmp_to(b.name) < 0)
	return buttons


func _make_small_icon(tex: Texture2D, size_px: int) -> Texture2D:
	if tex == null:
		return tex
	var img := tex.get_image()
	if img == null:
		return tex
	img.resize(size_px, size_px, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)


func _update_total_time() -> void:
	if total_label == null:
		return
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
		# Botões são instâncias novas quando a cena recarrega, então não duplica.
		btn.pressed.connect(_on_level_pressed.bind(i))


func _update_buttons() -> void:
	var max_levels: int = min(GameState.LEVEL_PAIRS.size(), level_buttons.size())
	for i in range(level_buttons.size()):
		var btn: Button = level_buttons[i]
		if btn == null:
			continue
		var should_show: bool = i < max_levels
		btn.visible = should_show
		if not should_show:
			continue

		var locked: bool = i > GameState.unlocked_level
		# Remove o "botão cinza" padrão e deixa só a imagem.
		btn.flat = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_stylebox_override("normal", _empty_style)
		btn.add_theme_stylebox_override("hover", _empty_style)
		btn.add_theme_stylebox_override("pressed", _empty_style)
		btn.add_theme_stylebox_override("disabled", _empty_style)
		btn.add_theme_stylebox_override("focus", _empty_style)
		btn.expand_icon = true
		btn.text = ""
		if locked:
			btn.icon = _icon_locked if _icon_locked != null else _lock_tex_small
		else:
			btn.icon = _icon_unlocked
		btn.disabled = locked


func _on_level_pressed(level_index: int) -> void:
	GameState.current_level = level_index
	get_tree().change_scene_to_file("res://scenes/levels/Level%d.tscn" % (level_index + 1))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
