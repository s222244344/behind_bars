extends Node2D

signal closed

@onready var panel: Control        = $Popup
@onready var label: RichTextLabel  = $Popup/Label

# --- knobs you can tweak in the inspector ---
@export var popup_size: Vector2   = Vector2(300, 140)   # size of the popup
@export var world_offset: Vector2 = Vector2(0, -16)     # shift above NPC (world units/pixels)
@export var screen_nudge = Vector2( +220, +160 )
	   # final nudge on screen (pixels)

var _lines: Array[String] = []
var _i: int = 0

func _ready() -> void:
	# Make sure Control placement is in screen space only
	panel.top_level = true

	# Hard reset any weird editor transforms
	scale = Vector2.ONE
	panel.scale = Vector2.ONE
	label.scale = Vector2.ONE

	panel.visible = false
	panel.z_index = 1000
	z_index = 1000
	_ensure_label_layout()

	# Give the panel a sane default size if it was 1×1
	panel.custom_minimum_size = popup_size
	if panel.size.x < 10 or panel.size.y < 10:
		panel.size = popup_size

func _ensure_label_layout() -> void:
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 12
	label.offset_top = 12
	label.offset_right = -12
	label.offset_bottom = -12
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_color_override("default_color", Color.WHITE)

# ---- Public: show at a SCREEN position (pixels from top-left of the window)
func show_dialogue_at_screen(screen_pos: Vector2, lines: Array[String]) -> void:
	_lines = lines.duplicate()
	_i = 0
	if _lines.is_empty(): return

	_ensure_label_layout()
	_update_label()
	visible = true
	panel.show()

	await get_tree().process_frame
	if panel.size.x < 10 or panel.size.y < 10:
		panel.size = popup_size

	var offset_y := 16.0
	# center horizontally over the point and put the bubble above it
	panel.global_position = (screen_pos + screen_nudge) - Vector2(panel.size.x * 0.5, panel.size.y + offset_y)
	set_process_unhandled_input(true)

# ---- Public: show above a WORLD position (e.g., an NPC)
func show_dialogue_at_world(world_pos: Vector2, lines: Array[String]) -> void:
	# apply pre-conversion world offset (e.g., raise above the head)
	world_pos += world_offset

	var cam: Camera2D = get_viewport().get_camera_2d()
	var screen_pos := world_pos
	if cam:
		# zoom-aware world -> screen:
		#   subtract camera center, apply zoom, then re-center to viewport
		var vp := get_viewport_rect().size
		screen_pos = (world_pos - cam.global_position) * cam.zoom + vp * 0.5
	show_dialogue_at_screen(screen_pos, lines)

# ---- Optional: centered helper
func show_dialogue(lines: Array[String]) -> void:
	_lines = lines.duplicate()
	_i = 0
	if _lines.is_empty(): return

	_ensure_label_layout()
	_update_label()
	visible = true
	panel.show()

	await get_tree().process_frame
	panel.global_position = get_viewport_rect().size * 0.5 - panel.size * 0.5
	set_process_unhandled_input(true)

func _update_label() -> void:
	label.text = _lines[_i]

func _advance() -> void:
	if _i + 1 < _lines.size():
		_i += 1
		_update_label()
	else:
		_close_dialogue()

func _close_dialogue() -> void:
	panel.hide()
	visible = false
	set_process_unhandled_input(false)
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) \
	or event.is_action_pressed("ui_accept") \
	or event.is_action_pressed("interact"):
		_advance()
