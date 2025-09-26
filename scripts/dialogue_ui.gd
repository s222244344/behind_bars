# res://scripts/dialogue_ui.gd
extends Node2D
class_name DialogueUI

signal closed

@onready var popup: Control = $Popup
@onready var text: RichTextLabel = $Popup/Label

var _lines: Array[String] = []
var _i := 0
var _active := false

func show_dialogue(lines: Array[String]) -> void:
	_lines = lines.duplicate()
	_i = 0
	_active = true
	popup.visible = true
	_update_label()

func _update_label() -> void:
	text.text = _lines[_i]

func _finish() -> void:
	popup.visible = false
	_active = false
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not _active: return
	if event.is_action_pressed("interact"):
		_i += 1
		if _i >= _lines.size():
			_finish()
		else:
			_update_label()
		get_viewport().set_input_as_handled()
