# res://scripts/end_zone.gd
extends Area2D

@export var lines: Array[String] = [
	"Congratulations, inmate!",
	"You’ve outsmarted the guards, uncovered the truth, and broken free.",
	"Your name is no longer chained to a crime you never committed.",
	"Through courage and cunning, you’ve proven your innocence and claimed your justice.",
	"The prison walls couldn’t hold you—freedom is finally yours."
]
@export var one_shot := true
var _hit := false

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_enter)

func _on_enter(body: Node) -> void:
	if _hit and one_shot: return
	if not body.is_in_group("player"): return
	_hit = true

	var ui := get_tree().get_first_node_in_group("dialogue_ui")
	if ui:
		get_tree().call_group("player", "set_process", false)
		ui.closed.connect(func():
			get_tree().call_group("player", "set_process", true)
			if one_shot: monitoring = false  # or queue_free()
		, CONNECT_ONE_SHOT)
		ui.show_dialogue(lines)
