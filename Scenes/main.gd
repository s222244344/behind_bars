# main.gd (minimal follow)
extends Node2D

var player: Node2D
var cam: Camera2D

func _ready() -> void:
	# Find player (prefer group)
	player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		player = get_node_or_null("player_scene/player") as Node2D
	if player == null:
		push_error("Player not found"); 
		return

	# Find a camera (prefer the one inside the player)
	cam = player.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		cam = get_node_or_null("player_scene/Camera2D") as Camera2D
	if cam == null:
		cam = get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		push_error("Camera2D not found");
		return

	cam.enabled = true  # make sure it’s the active camera

func _process(_dt: float) -> void:
	if cam != null and player != null:
		# keep camera centered on player
		cam.global_position = player.global_position
