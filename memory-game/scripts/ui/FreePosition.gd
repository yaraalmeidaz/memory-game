@tool
extends Control

var _enabled: bool = false
var _position_px: Vector2 = Vector2.ZERO
var _set_anchors: bool = true

var _applying_from_property := false
var _syncing_from_node := false

@export var enabled: bool = false:
	get:
		return _enabled
	set(value):
		_enabled = value
		_apply_from_property()

@export var position_px: Vector2 = Vector2.ZERO:
	get:
		return _position_px
	set(value):
		_position_px = value
		if _syncing_from_node:
			return
		_apply_from_property()

@export var set_anchors_top_left: bool = true:
	get:
		return _set_anchors
	set(value):
		_set_anchors = value
		_apply_from_property()

func _ready() -> void:
	# No editor, queremos que arrastar o nó atualize o position_px.
	# Em runtime, aplicamos a posição salva.
	if Engine.is_editor_hint():
		# Para Controls, item_rect_changed costuma ser o evento mais confiável.
		if not item_rect_changed.is_connected(_on_item_rect_changed):
			item_rect_changed.connect(_on_item_rect_changed)
		# Garante que NOTIFICATION_TRANSFORM_CHANGED dispare no editor.
		set_notify_transform(true)
		if _enabled:
			if _set_anchors:
				set_anchors_preset(Control.PRESET_TOP_LEFT)
			# Se não foi definido ainda, inicializa com a posição atual.
			if _position_px == Vector2.ZERO and position != Vector2.ZERO:
				_position_px = position
		return
	_apply_from_property()


func _on_item_rect_changed() -> void:
	if not Engine.is_editor_hint():
		return
	if not _enabled:
		return
	if _applying_from_property:
		return

	if position != _position_px:
		_syncing_from_node = true
		position_px = position
		_syncing_from_node = false

func _notification(what: int) -> void:
	if not Engine.is_editor_hint():
		return
	if not _enabled:
		return
	if _applying_from_property:
		return

	# Quando você move/arrasta o Control no editor, atualiza a propriedade exportada
	# para ela ser salva na cena e persistir ao rodar o jogo.
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if position != _position_px:
			_syncing_from_node = true
			position_px = position
			_syncing_from_node = false


func _apply_from_property() -> void:
	if not is_inside_tree():
		return
	if not _enabled:
		return

	# Importante: se este nó for filho de um Container (VBox/HBox/etc),
	# o Container pode sobrescrever posição/tamanho. Nesse caso, reposicione
	# o Container pai, ou tire este nó de dentro do Container.
	_applying_from_property = true
	if _set_anchors:
		set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = _position_px
	_applying_from_property = false
