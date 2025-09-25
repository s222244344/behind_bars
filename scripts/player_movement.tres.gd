extends CharacterBody2D

@export var movement_speed: float = 225
var character_direction: Vector2 = Vector2.ZERO

# ---------- inventory ----------
signal inventory_changed(inventory: Dictionary)
var inventory: Dictionary = {}

func _ready() -> void:
	# Ensure the HUD can always find us
	add_to_group("player")

func add_item(id: String, amount := 1) -> void:
	inventory[id] = inventory.get(id, 0) + amount
	print("[PLAYER] picked:", id, " total:", inventory[id])
	inventory_changed.emit(inventory)

func has_item(id: String, amount := 1) -> bool:
	return inventory.get(id, 0) >= amount

func remove_item(id: String, amount := 1) -> bool:
	var have := int(inventory.get(id, 0))
	if have >= amount:
		var left := have - amount
		if left > 0:
			inventory[id] = left
		else:
			inventory.erase(id)
		print("[PLAYER] used:", id, " left:", inventory.get(id, 0))
		inventory_changed.emit(inventory)
		return true
	return false
# --------------------------------

func _physics_process(_delta: float) -> void:
	character_direction.x = Input.get_axis("move_left", "move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")

	if character_direction.x > 0:
		%sprite.flip_h = false
	elif character_direction.x < 0:
		%sprite.flip_h = true

	if character_direction:
		velocity = character_direction * movement_speed
		if %sprite.animation != "Walking": %sprite.animation = "Walking"
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		if %sprite.animation != "Idle": %sprite.animation = "Idle"

	move_and_slide()
