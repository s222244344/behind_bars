# res://scripts/evidence_viewer.gd
extends CanvasLayer

@onready var overlay: ColorRect   = $ColorRect
@onready var image: TextureRect   = $Image
@onready var close_btn: Button    = $CloseBtn

func _ready() -> void:
	visible = false                    # also uncheck "Visible" in the inspector
	close_btn.pressed.connect(_on_close_pressed)

func show_image(tex: Texture2D) -> void:
	image.texture = tex
	visible = true
	get_tree().call_group("player", "set_process", false)  # optional: pause player

func _on_close_pressed() -> void:
	visible = false                    # <- renamed function
	get_tree().call_group("player", "set_process", true)   # optional: unpause
