# res://scripts/main.gd
extends Node2D

var player: Node2D
var cam: Camera2D

func _ready() -> void:
	# Find player (prefer group)
	player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		player = get_node_or_null("player_scene/player") as Node2D
	if player == null:
		push_error("Player not found")
		return

	# Find camera: (1) child of player, (2) sibling in player_scene, (3) root fallback
	cam = player.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		var p := player.get_parent()
		if p:
			cam = p.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		cam = get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		push_error("Camera2D not found")
		return

	cam.make_current()
	# If it lives under the player, keep it exactly centered.
	if cam.get_parent() == player:
		cam.position = Vector2.ZERO

	# Optional: turn off position smoothing while testing
	if "position_smoothing_enabled" in cam:
		cam.position_smoothing_enabled = false

func _process(_dt: float) -> void:
	# If the camera is NOT a child of the player (e.g., sibling), follow manually.
	if cam and player and cam.get_parent() != player:
		cam.global_position = player.global_position
