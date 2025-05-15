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
var fuel := 100.0 :
	set(value):
		if value >= 0.0 and value <= max_fuel:
			fuel = value
var max_fuel := 100.0
var fuel_regeneration := 10.0
var thrust_fuel_burn_multiplier := 2.5
var health := 50.0 :
	set(value):
		if value <= max_health and value >= 0.0:
			health = value
var max_health := 100.0
var repair_fuel_cost := 2.0
var max_repair_per_second := 10.0


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("increase_thrust"):
		_thrust += 1
	if Input.is_action_just_pressed("decrease_thrust"):
		_thrust -= 1
	
	var turning := Input.get_axis("right", "left")
	rotate(Vector3.UP, turning * delta * TAU * turn_speed)
	$Camera3D.global_rotation = Vector3(-PI/2, 0.0, 0.0)
	
	var delta_fuel := fuel_regeneration - _thrust * thrust_fuel_burn_multiplier
	
	if health < max_health and delta_fuel > 0.0:
		var repair_amount := minf(
			max_repair_per_second,
			floor(delta_fuel / repair_fuel_cost)
		)
		health += repair_amount * delta
		delta_fuel -= repair_fuel_cost * repair_amount
	
	fuel += delta_fuel * delta
	
	print("ship ", index, ": fuel ", round(fuel), " health ", round(health))
	
	move_and_collide(Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * delta * _thrust * 50)
