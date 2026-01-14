@tool
extends Control

var _enabled: bool = false
var _position_px: Vector2 = Vector2.ZERO
var _set_anchors: bool = true

@export var enabled: bool = false:
	get:
		return _enabled
	set(value):
		_enabled = value
		_apply()

@export var position_px: Vector2 = Vector2.ZERO:
	get:
		return _position_px
	set(value):
		_position_px = value
		_apply()

@export var set_anchors_top_left: bool = true:
	get:
		return _set_anchors
	set(value):
		_set_anchors = value
		_apply()

func _ready() -> void:
	_apply()

func _apply() -> void:
	if not is_inside_tree():
		return
	if not _enabled:
		return

	# Importante: se este nó for filho de um Container (VBox/HBox/etc),
	# o Container pode sobrescrever posição/tamanho. Nesse caso, reposicione
	# o Container pai, ou tire este nó de dentro do Container.
	if _set_anchors:
		set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = _position_px
