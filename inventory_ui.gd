extends CanvasLayer
@onready var panel: Panel = $Panel
@onready var list: ItemList = $Panel/VBoxContainer/ItemList
@onready var title: Label = $Panel/VBoxContainer/Label
var _player: Node = null

func _ready() -> void:
	panel.visible = false
	title.text = "Inventory"
	call_deferred("_late_connect")

func _late_connect() -> void:
	_player = get_tree().get_first_node_in_group("player")
	print("HUD: found player =", _player)
	if _player and _player.has_signal("inventory_changed"):
		_player.inventory_changed.connect(_update_list)
		_update_list(_player.inventory)

func _input(_e: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"): # 'I'
		panel.visible = not panel.visible
		if panel.visible and _player:
			_update_list(_player.inventory)

func _update_list(inv: Dictionary) -> void:
	list.clear()
	var ids := inv.keys()
	ids.sort()
	for id in ids:
		list.add_item("%s x%d" % [_pretty_name(str(id)), int(inv[id])])

func _pretty_name(id: String) -> String:
	match id:
		"key_blue":  return "Blue Key"
		"key_green": return "Green Key"
		"key_red":   return "Red Key"
		_:           return id
