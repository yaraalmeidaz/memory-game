extends Control

@export var level_index: int = 0

func _enter_tree() -> void:
	# Garante que a cena do nível seta o nível ANTES do GameScene.gd rodar _ready().
	GameState.current_level = level_index
