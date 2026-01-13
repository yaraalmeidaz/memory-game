extends Control

@onready var name_edit: LineEdit = $VBox/NameEdit
@onready var start_button: Button = $VBox/Start

func _ready() -> void:
	name_edit.grab_focus()
	_on_name_changed(name_edit.text)

func _on_name_changed(new_text: String) -> void:
	start_button.disabled = new_text.strip_edges() == ""

func _on_start_pressed() -> void:
	GameState.start_new_run(name_edit.text)
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")
