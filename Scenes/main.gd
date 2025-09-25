# res://scripts/main.gd
extends Node2D

# --- Camera follow ---
var player: Node2D
var cam: Camera2D

# --- Caught UI ---
@onready var ui_layer: CanvasLayer = $CaughtUI
@onready var ui_label: Label      = $CaughtUI/Panel/Label
@onready var timer: Timer         = $CaughtUI/Timer

var caught := false

func _ready() -> void:
	# --- find player ---
	player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		player = get_node_or_null("player_scene/player") as Node2D
	if player == null:
		push_error("Player not found")
		return

	# --- find camera (prefer child on player) ---
	cam = player.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		cam = get_node_or_null("player_scene/Camera2D") as Camera2D
	if cam == null:
		cam = get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		push_error("Camera2D not found")
		return

	cam.make_current()                 # ensure it’s the active camera
	if cam.get_parent() == player:
		cam.position = Vector2.ZERO    # camera sits exactly at player origin

	# --- UI setup ---
	add_to_group("game")
	if ui_layer == null or ui_label == null or timer == null:
		push_warning("CaughtUI/Label/Timer not found in scene.")
		return

	ui_layer.visible = false
	timer.one_shot = true
	timer.timeout.connect(_on_caught_timeout)

	# listen to all cops present now
	for cop in get_tree().get_nodes_in_group("cops"):
		cop.spotted.connect(_on_player_spotted)

func _process(_dt: float) -> void:
	# Only do manual following if the camera is NOT a child of the player.
	if cam != null and player != null and cam.get_parent() != player:
		cam.global_position = player.global_position

# --- caught flow ---
func _on_player_spotted(_player: Node) -> void:
	caught = true
	ui_label.text = "Caught! Get back to your cell in 5 seconds!"
	ui_layer.visible = true
	timer.start(5.0)

func cancel_caught() -> void:
	caught = false
	timer.stop()
	ui_layer.visible = false

func _on_caught_timeout() -> void:
	if not caught:
		return
	get_tree().reload_current_scene()
