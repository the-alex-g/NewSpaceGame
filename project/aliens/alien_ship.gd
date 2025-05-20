extends CharacterBody3D

@export var speed := 2.0
@export var turn_speed := 0.1
@export var asteroid_layer := true

var _turn_direction := randi() % 3 - 1
var _health := 150.0

@onready var _animation_player := $xeno_spaceship_0/AnimationPlayer
@onready var _asteroid_timer := $AsteroidTimer


func _ready() -> void:
	_animation_player.play("ArmatureAction")
	_animation_player.seek(
		lerpf(0.0, _animation_player.current_animation_length, randf())
	)
	
	if asteroid_layer:
		_asteroid_timer.start()


func _physics_process(delta: float) -> void:
	rotate(Vector3.UP, TAU * delta * turn_speed * _turn_direction)
	move_and_collide(_get_forward_vector() * speed * delta)


func _get_forward_vector() -> Vector3:
	return Vector3.FORWARD.rotated(Vector3.UP, rotation.y)


func _on_turn_timer_timeout() -> void:
	_turn_direction = randi() % 3 - 1
	$TurnTimer.wait_time = lerpf(0.5, 3.0, randf())


func damage(amount: float) -> void:
	_health -= amount
	if _health <= 0:
		_spawn_asteroid()
		queue_free()


func _spawn_asteroid(backwards := false) -> void:
	var asteroid := preload("res://asteroid/asteroid.tscn").instantiate()
	var asteroid_position := global_position
	if backwards:
		asteroid_position -= _get_forward_vector() * 10
	else:
		asteroid.radius = 6.0
	get_parent().add_child(asteroid)
	asteroid.global_position = asteroid_position
	if backwards:
		asteroid.apply_impulse(-_get_forward_vector() * 3)


func _on_asteroid_timer_timeout() -> void:
	_spawn_asteroid(true)
	_asteroid_timer.wait_time = lerpf(5.0, 10.0, randf())
