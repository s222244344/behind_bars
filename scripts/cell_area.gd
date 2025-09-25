extends Area2D

func _ready() -> void:
	body_entered.connect(_on_enter)

func _on_enter(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var game := get_tree().get_first_node_in_group("game")
	if game:
		game.cancel_caught()
