# res://scripts/camera_detector.gd
extends Node2D

# --- options ---
@export var sweep := false                 # pan back & forth
@export var sweep_speed := 25.0            # degrees/sec
@export var sweep_range := Vector2(-45, 45)# min/max degrees

@export var use_line_of_sight := false     # raycast check (optional)
@export var los_mask: int = 1              # walls layer if using LOS

@export var alarm_duration := 3.0          # seconds before reset
@export var respawn_on_catch := true       # reload scene after alarm
@export var cancel_alarm_on_exit := true   # stop siren/timer if player leaves

# --- nodes ---
@onready var vision: Area2D            = $Vision
@onready var siren: AudioStreamPlayer2D = $Siren
@onready var timer: Timer              = $Timer

var _dir := 1
var _triggered := false

func _ready() -> void:
	vision.body_entered.connect(_on_vision_entered)
	vision.body_exited.connect(_on_vision_exited)
	if timer:
		timer.one_shot = true
		timer.timeout.connect(_on_timeout)

func _process(delta: float) -> void:
	if sweep:
		rotation_degrees += _dir * sweep_speed * delta
		if rotation_degrees > sweep_range.y or rotation_degrees < sweep_range.x:
			_dir *= -1

func _on_vision_entered(body: Node) -> void:
	if _triggered: return
	if not body.is_in_group("player"): return

	if use_line_of_sight:
		var params := PhysicsRayQueryParameters2D.create(global_position, body.global_position)
		params.exclude = [self, vision]
		params.collision_mask = los_mask
		var hit := get_world_2d().direct_space_state.intersect_ray(params)
		if hit and hit.collider != body:
			return

	_triggered = true
	if siren:
		siren.stop()
		siren.play()
	if timer:
		timer.start(alarm_duration)

func _on_vision_exited(body: Node) -> void:
	if not cancel_alarm_on_exit: return
	if not body.is_in_group("player"): return

	if siren and siren.playing:
		siren.stop()
	if timer and not timer.is_stopped():
		timer.stop()
	_triggered = false

func _on_timeout() -> void:
	# Decrement the day first
	get_tree().call_group("day_counter", "dec_day")

	if respawn_on_catch:
		get_tree().reload_current_scene()

	_triggered = false
	if siren and siren.playing:
		siren.stop()
