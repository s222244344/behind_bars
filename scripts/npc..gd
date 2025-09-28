extends CharacterBody2D

@export var speed: float = 65.0
@export var move_time := Vector2(0.6, 1.6)   # [min,max] seconds while moving
@export var rest_time := Vector2(0.7, 1.5)   # [min,max] seconds while idling
@export var four_directions := true          # true=N/S/E/W only

# Set these to your actual animation names
@export var anim_idle: String = "Idle"
@export var anim_walk: String = "Walking"

@onready var sprite: AnimatedSprite2D = $sprite

var _rng := RandomNumberGenerator.new()
var _dir := Vector2.ZERO
var _state := "idle"     # "idle" or "move"
var _time_left := 0.0

func _ready() -> void:
	_rng.randomize()
	_pick_idle()

func _physics_process(delta: float) -> void:
	_time_left -= delta

	if _state == "move":
		velocity = _dir * speed
		move_and_slide()
		if is_on_wall() or is_on_floor() or is_on_ceiling():
			_pick_move()
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
	_dir = _random_direction()

func _pick_idle(duration: float = -1.0) -> void:
	_state = "idle"
	_time_left = duration if duration > 0.0 else _rng.randf_range(rest_time.x, rest_time.y)
	_dir = Vector2.ZERO
	if sprite and anim_idle != "":
		sprite.play(anim_idle)

func _random_direction() -> Vector2:
	if four_directions:
		var dirs := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
		return dirs[_rng.randi_range(0, dirs.size() - 1)]
	var ang := _rng.randf() * TAU
	return Vector2(cos(ang), sin(ang)).normalized()

func _update_sprite() -> void:
	if sprite == null:
		return
	sprite.flip_h = _dir.x < 0
	var anim: String = anim_walk if _state == "move" else anim_idle
	if sprite.animation != anim and anim != "":
		sprite.play(anim)
