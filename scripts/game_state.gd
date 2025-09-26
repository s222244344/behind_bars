# res://scripts/day_counter.gd
extends CanvasLayer

@export var starting_days: int = 14
@onready var label: Label = $DayLabel

var days: int

const SAVE_PATH := "user://days.cfg"
const SAVE_SECTION := "meta"
const SAVE_KEY := "days_left"

func _ready() -> void:
	days = _load_days()
	_update_label()

func dec_day() -> void:
	days = max(0, days - 1)
	_update_label()
	_save_days()

func reset_days() -> void:
	days = starting_days
	_update_label()
	_save_days()

func _update_label() -> void:
	if label:
		label.text = "Day: %d" % days

func _save_days() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH) # ignore errors
	cfg.set_value(SAVE_SECTION, SAVE_KEY, days)
	cfg.save(SAVE_PATH)

func _load_days() -> int:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == OK and cfg.has_section_key(SAVE_SECTION, SAVE_KEY):
		return int(cfg.get_value(SAVE_SECTION, SAVE_KEY))
	return starting_days
