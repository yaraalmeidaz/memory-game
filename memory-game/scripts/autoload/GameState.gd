extends Node

const LEVEL_PAIRS: Array[int] = [2, 4, 5, 7, 9, 12]
const LEADERBOARD_PATH := "user://leaderboard.cfg"

var player_name: String = ""
var unlocked_level: int = 0 # 0..5
var current_level: int = 0
var level_times: Array[float] = [] # seconds, size 6

var _run_start_msec: int = 0

func _ready() -> void:
	_reset_run_state()

func _reset_run_state() -> void:
	unlocked_level = 0
	current_level = 0
	level_times = []
	level_times.resize(LEVEL_PAIRS.size())
	for i in level_times.size():
		level_times[i] = -1.0
	_run_start_msec = Time.get_ticks_msec()

func start_new_run(name: String) -> void:
	player_name = name.strip_edges()
	_reset_run_state()

func get_pairs_for_level(level_index: int) -> int:
	return LEVEL_PAIRS[clamp(level_index, 0, LEVEL_PAIRS.size() - 1)]

func record_level_time(level_index: int, seconds: float) -> void:
	if level_index < 0 or level_index >= level_times.size():
		return
	level_times[level_index] = maxf(0.0, seconds)

func get_total_time() -> float:
	var total := 0.0
	for t in level_times:
		if t < 0:
			return -1.0
		total += t
	return total

func complete_level(level_index: int, seconds: float) -> void:
	record_level_time(level_index, seconds)
	if level_index == unlocked_level and unlocked_level < LEVEL_PAIRS.size() - 1:
		unlocked_level += 1

func is_campaign_complete() -> bool:
	for t in level_times:
		if t < 0:
			return false
	return true

func _load_leaderboard() -> Array[Dictionary]:
	var cfg := ConfigFile.new()
	var err := cfg.load(LEADERBOARD_PATH)
	if err != OK:
		return []

	var entries: Array[Dictionary] = []
	var count := int(cfg.get_value("meta", "count", 0))
	for i in count:
		var section := "entry_%d" % i
		var n := str(cfg.get_value(section, "name", ""))
		var t := float(cfg.get_value(section, "time", 999999.0))
		if n != "":
			entries.append({"name": n, "time": t})
	return entries

func _save_leaderboard(entries: Array[Dictionary]) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "count", entries.size())
	for i in entries.size():
		var section := "entry_%d" % i
		cfg.set_value(section, "name", entries[i]["name"])
		cfg.set_value(section, "time", entries[i]["time"])
	cfg.save(LEADERBOARD_PATH)

func submit_run_to_leaderboard() -> void:
	var total := get_total_time()
	if total < 0:
		return
	if player_name.strip_edges() == "":
		return

	var entries := _load_leaderboard()
	entries.append({"name": player_name, "time": total})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["time"]) < float(b["time"]))
	if entries.size() > 5:
		entries.resize(5)
	_save_leaderboard(entries)

func get_top5() -> Array[Dictionary]:
	var entries := _load_leaderboard()
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["time"]) < float(b["time"]))
	if entries.size() > 5:
		entries.resize(5)
	return entries

func format_time(seconds: float) -> String:
	if seconds < 0:
		return "--:--"
	var s := int(round(seconds))
	var m := s / 60
	s = s % 60
	return "%02d:%02d" % [m, s]
