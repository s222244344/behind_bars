# res://scripts/npc8.gd
extends Node2D

# Lines you’ll see for THIS NPC only
@export var lines: Array[String] = [
	"You got a deathwish inmate?",
	"Either you can stand there and cause trouble...",
	"Or I could save your life and give you some advice",
	"Some rumours have been going around about your plan",
	"You do some things for me ill be glad to help you out",
	"First you have to know how this prison works",
	"red walls = cells, inamtes",
	"blue walls = offices, cop rooms, storage rooms",
	"green walls = hallways",
	"dont be fooled by all the walls, you can walk...",
	"through them sometimes and they may lead you to what your looking for",
	"Now get the hell out site unless you plan on unlocking my cell"
]

# Optional: show an on-screen hint (e.g., “E”) when player is in range
@export var show_prompt := true

var _player_in := false
@onready var _interact: Area2D = $Interact
@onready var _prompt: Node2D = $Prompt if has_node("Prompt") else null  # optional sprite/label

func _ready() -> void:
	_interact.body_entered.connect(_on_enter)
	_interact.body_exited.connect(_on_exit)
	if _prompt:
		_prompt.visible = false

func _on_enter(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in = true
		if _prompt and show_prompt:
			_prompt.visible = true

func _on_exit(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in = false
		if _prompt:
			_prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in: return
	if event.is_action_pressed("interact"):
		var ui := get_tree().get_first_node_in_group("dialogue_ui")
		if ui:
			# (Optional) freeze player movement during dialogue
			get_tree().call_group("player", "set_process", false)
			ui.closed.connect(func():
				get_tree().call_group("player", "set_process", true)
			, CONNECT_ONE_SHOT)
			ui.show_dialogue(lines)
			get_viewport().set_input_as_handled()
