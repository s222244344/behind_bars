extends Area2D

@export var item_id := "key_blue"
@export var amount := 1

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.add_item(item_id, amount)
		queue_free()
