extends CanvasLayer

@onready var popup: Control = $Popup               # <- direct child
@onready var text: RichTextLabel = $Popup/Label    # or Label, match your node type

signal closed

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
