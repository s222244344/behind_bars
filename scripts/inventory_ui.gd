extends CanvasLayer
# If your UI root is a Control instead, change to: extends Control

# Order & look of keys in the HUD
const KEYS := [
	{"id": "key_blue",  "label": "Blue",  "color": Color8( 80,160,255)},
	{"id": "key_green", "label": "Green", "color": Color8( 90,220,120)},
	{"id": "key_red",   "label": "Red",   "color": Color8(230, 80, 80)},
]

@onready var row: HBoxContainer = $Panel/Row
var _slots: Dictionary = {}  # id -> VBoxContainer

func _ready() -> void:
	_make_slots()

	# Bind to the player inventory signal
	var p := get_tree().get_first_node_in_group("player")
	if p:
		p.inventory_changed.connect(_on_inventory_changed)
		_on_inventory_changed(p.inventory)  # initial fill
	else:
		# Player might spawn a frame later
		call_deferred("_late_bind")

	visible = true  # or false if you want it hidden by default

func _late_bind() -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p and not p.inventory_changed.is_connected(_on_inventory_changed):
		p.inventory_changed.connect(_on_inventory_changed)
		_on_inventory_changed(p.inventory)

func _make_slots() -> void:
	for k in KEYS:
		var vb := VBoxContainer.new()
		vb.custom_minimum_size = Vector2(40, 40)
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(vb)

		var swatch := ColorRect.new()
		swatch.color = k["color"]
		swatch.custom_minimum_size = Vector2(32, 18)
		swatch.tooltip_text = k["label"]
		vb.add_child(swatch)

		var count := Label.new()
		count.name = "Count"
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count.text = "0"
		vb.add_child(count)

		_slots[k["id"]] = vb

func _on_inventory_changed(inv: Dictionary) -> void:
	for k in KEYS:
		var id: String = k["id"]
		var have: int = int(inv.get(id, 0))
		var vb: Control = _slots.get(id)
		if vb == null:
			continue
		vb.modulate.a = 1.0 if have > 0 else 0.35
		(vb.get_node("Count") as Label).text = str(have)

func _unhandled_input(event: InputEvent) -> void:
	# Optional: toggle with your "inventory" action (e.g., I)
	if event.is_action_pressed("inventory"):
		visible = not visible
