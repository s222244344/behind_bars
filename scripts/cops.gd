extends CharacterBody2D

@export var speed: float = 70.0
@export var move_time := Vector2(0.6, 1.4)
@export var rest_time := Vector2(0.6, 1.0)
@export var use_line_of_sight := false

@onready var sprite: AnimatedSprite2D = %Sprite    # matches your node name
@onready var vision: Area2D          = %Vision

signal spotted(player: Node)

var _rng := RandomNumberGenerator.new()
var _dir := Vector2.ZERO
var _state := "idle"
var _time_left := 0.0

func _ready() -> void:
	add_to_group("cops")
	_rng.randomize()
	_pick_idle()
	vision.body_entered.connect(_on_vision_entered)

func _physics_process(delta: float) -> void:
	_time_left -= delta

	if _state == "move":
		velocity = _dir * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

	if _time_left <= 0.0:
		if _state == "move":
			_pick_idle()
		else:
			_pick_move()

	_update_sprite()

func _pick_move() -> void:
	_state = "move"
	_time_left = _rng.randf_range(move_time.x, move_time.y)
	var dirs := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	_dir = dirs[_rng.randi_range(0, dirs.size() - 1)]

func _pick_idle() -> void:
	_state = "idle"
	_time_left = _rng.randf_range(rest_time.x, rest_time.y)
	_dir = Vector2.ZERO

func _update_sprite() -> void:
	if not sprite: return
	if _dir.x != 0:
		sprite.flip_h = _dir.x < 0
	# Use Python-style ternary in Godot 4:
	var anim := "walking" if _state == "move" else "idle"
	if sprite.animation != anim:
		sprite.play(anim)

func _on_vision_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if use_line_of_sight:
		var params := PhysicsRayQueryParameters2D.create(global_position, body.global_position)
		params.exclude = [self, vision]     # ignore self & vision shape
		# params.collision_mask = 1        # optional: walls-only mask
		var hit := get_world_2d().direct_space_state.intersect_ray(params)
		if hit and hit.collider != body:
			return
	spotted.emit(body)
