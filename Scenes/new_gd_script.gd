extends Area2D

func _on_key_body_entered(body: Node) -> void:
	# Player is a physics body and we added add_item() earlier
	if body.has_method("add_item"):
		body.add_item("key", 1)
		queue_free()
		
		  # remove the key after pickup
