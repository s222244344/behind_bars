# res://scripts/door.gd
extends Node2D

@export var required_key_id: String = "key_blue"
@export var consume_key: bool = true
@export var temporary_open: bool = false
@export var reopen_after: float = 2.0

var _player: Node = null

@onready var _collider: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	if _collider:
		_collider.disabled = false

func _process(_delta: float) -> void:
	if _player and Input.is_action_just_pressed("interact"):
		_try_open()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body

func _on_body_exited(body: Node) -> void:
	if body == _player:
		_player = null

func _try_open() -> void:
	if not _player:
		return
	if _player.has_method("has_item") and _player.has_item(required_key_id, 1):
		if consume_key and _player.has_method("remove_item"):
			_player.remove_item(required_key_id, 1)
		_open()
	else:
		print("Locked: need", required_key_id)

func _open() -> void:
	if _collider:
		_collider.disabled = true
	if _sprite:
		_sprite.modulate.a = 0.35  # optional visual fade

	if temporary_open:
		var t := get_tree().create_timer(reopen_after)
		t.timeout.connect(_relock)

func _relock() -> void:
	if _collider:
		_collider.disabled = false
	if _sprite:
		_sprite.modulate.a = 1.0
