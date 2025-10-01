extends Node2D

@export var lines: Array[String] = [
	"What could you possibly need from me?",
	"I’ve heard about your plan. Risky… maybe genius, maybe foolish.",
	"But I also heard why you’re in here — and even criminals know that ain’t right.",
	"Still, you pulled it off. Smart move sneaking past the guard to get here.",
	"And if you unlocked your own cell instead? That’s just as sharp — bold and quick thinking.",
	"Either way, you’ve got more brains than most in this place.",
	"Listen: an inmate swiped a guard’s key near the basketball court.",
	"That key gets you into the break room.",
	"From there, hug the walls and slip past the cops on their breaks — they hardly look up.",
	"Search the desks; one of them hides another key.",
	"That key opens the evidence room.",
	"Don’t waste keys, don’t linger, and move when the hall is loud.",
	"There may be something else hidden within the evidence draws and that could be your way out of here..."
]


@export var show_prompt := true

# --- Positioning controls ---
@export var bubble_anchor_path: NodePath = ^"Interact/CollisionShape2D"
@export var bubble_offset: Vector2 = Vector2(120, -60)  # nudge from anchor (right & up)
@export var use_fixed_position := false                  # set true to use the value below
@export var fixed_world_pos: Vector2 = Vector2(816, 492) # your red-rectangle target
# ----------------------------

var _player_in := false
@onready var _interact: Area2D = $Interact
@onready var _prompt: Node2D = $Prompt if has_node("Prompt") else null

func _ready() -> void:
	_interact.body_entered.connect(_on_enter)
	_interact.body_exited.connect(_on_exit)
	if _prompt:
		_prompt.visible = false
	set_process_unhandled_input(true)

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

func _get_anchor_world_pos() -> Vector2:
	if bubble_anchor_path != NodePath() and has_node(bubble_anchor_path):
		var n := get_node(bubble_anchor_path)
		if n is Node2D:
			return (n as Node2D).global_position
	return global_position

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in:
		return

	var pressed := event.is_action_pressed("interact")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = true
	if not pressed:
		return

	var ui = get_tree().get_first_node_in_group("dialogue_ui")
	if ui:
		get_tree().call_group("player", "set_process", false)
		ui.closed.connect(func():
			get_tree().call_group("player", "set_process", true)
		, CONNECT_ONE_SHOT)

		var world_target: Vector2 = fixed_world_pos if use_fixed_position \
			else _get_anchor_world_pos() + bubble_offset

		ui.show_dialogue_at_world(world_target, lines)
		get_viewport().set_input_as_handled()
