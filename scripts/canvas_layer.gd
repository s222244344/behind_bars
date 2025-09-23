# res://scripts/npc.gd
extends Node2D

@export var lines: Array[String] = [
	"Hey there.",
	"Keys open doors. Color must match!",
	"Good luck!"
]

var _player: Node = null
var _index: int = 0
var _ui: PopupUI

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	_ui = get_tree().get_first_node_in_group("dialog_ui") as PopupUI

func _process(_dt: float) -> void:
	if _player and Input.is_action_just_pressed("interact"):
		_talk()

func _talk() -> void:
	if _ui == null: return
	if _index < lines.size():
		_ui.show_message(lines[_index])
		_index += 1
	else:
		_index = 0
		_ui.hide_message()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body

func _on_body_exited(body: Node) -> void:
	if body == _player:
		_player = null
		_index = 0
		if _ui: _ui.hide_message()
