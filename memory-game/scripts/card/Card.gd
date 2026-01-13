class_name Card
extends Node2D

signal pressed(card: Card)

var _flipped := false
var matched := false

@export var personagem: String = ""

@onready var card_back: Sprite2D = $CardBack
@onready var card_front: Sprite2D = $CardBack/CardFront
@onready var personagem_sprite: Sprite2D = $CardBack/CardFront/Personagem
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const _PERSONAGEM_FILL := 0.82


func _ready() -> void:
	# estado inicial
	card_front.visible = false
	personagem_sprite.visible = false
	card_back.visible = true

	set_process_unhandled_input(true)

	# carregar imagem do personagem
	if personagem != "":
		var path := "res://assets/imagens/Personagens/%s.png" % personagem
		if ResourceLoader.exists(path):
			personagem_sprite.texture = load(path)
			_fit_personagem()
		else:
			push_error("Imagem não encontrada: " + path)

	matched = false
	_flipped = false
	personagem_sprite.position = Vector2.ZERO


func _fit_personagem() -> void:
	# Centraliza e ajusta escala do personagem para ocupar bem a frente da carta.
	if personagem_sprite.texture == null:
		return
	if card_front.texture == null:
		return

	personagem_sprite.centered = true
	personagem_sprite.position = Vector2.ZERO

	var tex_size: Vector2 = personagem_sprite.texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return

	var front_size: Vector2 = card_front.texture.get_size()
	var target: Vector2 = front_size * _PERSONAGEM_FILL
	var sx: float = target.x / tex_size.x
	var sy: float = target.y / tex_size.y
	var s: float = minf(sx, sy)
	personagem_sprite.scale = Vector2.ONE * s


func reveal() -> void:
	if matched:
		return
	if _flipped:
		return
	_card_up()


func conceal() -> void:
	if matched:
		return
	if not _flipped:
		return
	_card_down()


func flip() -> void:
	if animation_player.is_playing():
		return

	if _flipped:
		_card_down()
	else:
		_card_up()


func _card_up() -> void:
	animation_player.play("flip-up")
	card_front.visible = true
	personagem_sprite.visible = true
	_flipped = true


func _card_down() -> void:
	animation_player.play("flip-down")
	personagem_sprite.visible = false
	card_front.visible = false
	_flipped = false


func _on_area_2d_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		if matched:
			return
		pressed.emit(self)


func _unhandled_input(event: InputEvent) -> void:
	# Fallback: garante clique mesmo se Area2D não disparar input_event
	if matched:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var w: float = 725.0 * scale.x
		var h: float = 1102.0 * scale.y
		var rect := Rect2(Vector2(-w * 0.5, -h * 0.5), Vector2(w, h))
		var local := to_local(get_global_mouse_position())
		if rect.has_point(local):
			pressed.emit(self)
