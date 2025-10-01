# res://scripts/file_cabinet.gd
extends Area2D

@export var evidence_image: Texture2D
@export var by_click := false
@export var show_prompt := true

var _player_in := false
@onready var _prompt: Node2D = $Prompt if has_node("Prompt") else null

func _ready() -> void:
	input_pickable = true
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	if _prompt: _prompt.visible = false
	if by_click:
		input_event.connect(_on_input_event)  # precise mouse picking on this Area2D

func _on_enter(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in = true
		if _prompt and show_prompt: _prompt.visible = true

func _on_exit(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in = false
		if _prompt: _prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not by_click and _player_in and event.is_action_pressed("interact"):
		_open_evidence()

func _on_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if by_click and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_open_evidence()

func _open_evidence() -> void:
	if evidence_image == null:
		push_warning("No evidence_image set on file_cabinet.gd")
		return
	var ui := get_tree().get_first_node_in_group("evidence_viewer")
	if ui:
		ui.show_image(evidence_image)
		get_viewport().set_input_as_handled()
