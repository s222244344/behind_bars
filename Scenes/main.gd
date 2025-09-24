extends Node2D

@onready var tm_root: TileMap   = $TileMap
@onready var spawn:   Marker2D  = $TileMap.get_node_or_null("Spawn")

var player: Node2D
var cam: Camera2D

const ZOOM := Vector2(0.9, 0.9)   # < 1 = zoom in a bit

func _ready() -> void:
	# 1) Find the player (group preferred)
	player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		player = get_node_or_null("player_scene/player") as Node2D
	if player == null:
		push_error("Player not found"); return

	# 2) Move to spawn (optional)
	if spawn:
		player.global_position = spawn.global_position

	# 3) Find a camera; prefer the one under the player
	cam = player.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		cam = get_node_or_null("player_scene/Camera2D") as Camera2D
	if cam == null:
		push_error("Camera2D not found"); return

	# 4) Reparent camera under player so it stays centered automatically
	if cam.get_parent() != player:
		var p := cam.get_parent()
		if p: p.remove_child(cam)
		player.add_child(cam)
	cam.position = Vector2.ZERO

	# 5) Camera setup
	cam.enabled = true
	cam.offset = Vector2.ZERO
	cam.position_smoothing_enabled = false
	cam.position_smoothing_speed = 6.0
	cam.zoom = ZOOM

	# 6) Make sure player sprite is visible (defensive)
	var spr := player.get_node_or_null("sprite") as CanvasItem
	if spr:
		spr.visible = true
		spr.modulate.a = 1.0
