# res://scripts/intro_ui.gd
extends CanvasLayer

signal closed

@export var default_lines: Array[String] = [
	"[center][b]Welcome to Behind Bars[/b][/center]",
	"",
	"[b]Controls[/b]",
	"• WASD to move",
	"• [b]Left click[/b] to interact and [b]ENTER[/b] to read more or continue interactions",
	"• your [b]inventroy[/b] is on the top right of your screen, it displays the different types of keys you have in your body",
	"",
	"Avoid the guards’ and camera, collect evidence and find a way out.",
	"Different keys unlock different doors in the game",
	"",
	"When near a door interact to unlock",
	"",
	"if you get caught, you will spawn back in your cell",
	"",
	"Getting caught = [b] CLOSER DAY OF DEATH[/b]",
	"",
	"",
	"",
	"[i]Click, Enter to continue…[/i]",
	"",
	"",
	"",
	"[center][b]Good luck...[/b]"
]

@onready var panel: Panel = $Panel
@onready var label: RichTextLabel = $Panel/Label

func _ready() -> void:
	# Fill the screen with a margin
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	const M := 64
	panel.offset_left = M
	panel.offset_top = M
	panel.offset_right = -M
	panel.offset_bottom = -M

	# Label fills the panel with padding
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	const P := 24
	label.offset_left = P
	label.offset_top = P
	label.offset_right = -P
	label.offset_bottom = -P
	label.bbcode_enabled = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD

	visible = false
	panel.visible = false
	set_process_unhandled_input(false)

func show_intro(lines: Array[String] = []) -> void:
	
	var to_show: Array[String] = lines if lines.size() > 0 else default_lines
	label.text = "\n".join(to_show)
	visible = true
	panel.visible = true
	await get_tree().process_frame
	set_process_unhandled_input(true)

func _close() -> void:
	set_process_unhandled_input(false)
	panel.visible = false
	visible = false
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) \
	or event.is_action_pressed("ui_accept") \
	or event.is_action_pressed("interact"):
		_close()
