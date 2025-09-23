# res://scripts/key.gd
extends Area2D

@export var key_id: String = "key_blue"  # set per instance in the Inspector

func _ready() -> void:
	monitoring = true
	if $CollisionShape2D:
		$CollisionShape2D.disabled = false
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# Accept any body that can store items (your player has add_item)
	if body.has_method("add_item"):
		body.add_item(key_id, 1)
		print("Key picked:", key_id)
		queue_free()
