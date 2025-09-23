extends Area2D

@export var key_id: String = "key_green"  # set per-instance in the Inspector

func _ready() -> void:
	monitoring = true
	var cs := $CollisionShape2D
	if cs: cs.disabled = false
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	print("[KEY] ready id=", key_id, " node=", name)

func _on_body_entered(body: Node) -> void:
	print("[KEY] touched by:", body.name)
	if body.is_in_group("player") and body.has_method("add_item"):
		body.add_item(key_id, 1)
		print("[KEY] picked:", key_id)
		queue_free()
