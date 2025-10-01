extends Node
class_name InventoryStore

signal changed(inv: Dictionary)

var inv: Dictionary = {}   # { id: count }

func add(id: String, amount := 1) -> void:
	inv[id] = inv.get(id, 0) + amount
	changed.emit(inv)

func remove(id: String, amount := 1) -> bool:
	var n := int(inv.get(id, 0))
	if n >= amount:
		n -= amount
		if n > 0:
			inv[id] = n
		else:
			inv.erase(id)
		changed.emit(inv)
		return true
	return false

func has(id: String, amount := 1) -> bool:
	return inv.get(id, 0) >= amount
