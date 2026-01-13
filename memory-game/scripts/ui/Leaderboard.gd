extends Control

@onready var your_time: Label = $VBox/YourTime
@onready var list_box: VBoxContainer = $VBox/List

func _ready() -> void:
	var total := GameState.get_total_time()
	your_time.text = "Seu tempo: %s" % GameState.format_time(total)

	for c in list_box.get_children():
		c.queue_free()

	var top := GameState.get_top5()
	if top.is_empty():
		var lbl := Label.new()
		lbl.text = "(Sem resultados ainda)"
		list_box.add_child(lbl)
		return

	for i in top.size():
		var e: Dictionary = top[i]
		var lbl := Label.new()
		lbl.text = "%d) %s — %s" % [i + 1, str(e["name"]), GameState.format_time(float(e["time"]))]
		list_box.add_child(lbl)

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
