extends CharacterBody3D

@export var turn_speed := 0.5

var index := 0
var _thrust := 0 :
	set(value):
		if value <= max_thrust and value >= 0:
			_thrust = value
	get():
		if _thrust * thrust_fuel_burn_multiplier > fuel:
			_thrust = floor(fuel / thrust_fuel_burn_multiplier)
		return _thrust
var max_thrust := 6
var fuel := 0.0 :
	set(value):
		if value >= 0.0 and value <= max_fuel:
			fuel = value
var max_fuel := 100.0
var fuel_regeneration := 10.0
var thrust_fuel_burn_multiplier := 2.5


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("increase_thrust"):
		_thrust += 1
	if Input.is_action_just_pressed("decrease_thrust"):
		_thrust -= 1
	
	var turning := Input.get_axis("right", "left")
	rotate(Vector3.UP, turning * delta * TAU * turn_speed)
	$Camera3D.global_rotation = Vector3(-PI/2, 0.0, 0.0)
	
	fuel += fuel_regeneration * delta
	fuel -= _thrust * delta * thrust_fuel_burn_multiplier
	print(fuel)
	
	move_and_collide(Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * delta * _thrust * 50)
