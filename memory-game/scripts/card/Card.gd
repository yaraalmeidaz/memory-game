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


func _ready() -> void:
	# estado inicial
	card_front.visible = false
	personagem_sprite.visible = false
	card_back.visible = true

	# carregar imagem do personagem
	if personagem != "":
		var path := "res://assets/imagens/Personagens/%s.png" % personagem
		if ResourceLoader.exists(path):
			personagem_sprite.texture = load(path)
		else:
			push_error("Imagem não encontrada: " + path)

	matched = false
	_flipped = false


func reveal() -> void:
	if matched:
		return
	if _flipped:
		return
	_card_up()


func hide() -> void:
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
