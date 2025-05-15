class_name Player
extends CharacterBody3D

signal missile_launch_requested(player: Player)

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
var thrust_speed_multiplier := 2.0
var speed : float :
	get():
		return _thrust * thrust_speed_multiplier
var health := 50.0 :
	set(value):
		if value <= max_health and value >= 0.0:
			health = value
var max_health := 100.0
var repair_fuel_cost := 2.0
var phaser_fuel_cost := 5
var phaser_damage := 10.0
var phaser_cooldown_time := 0.25
var _can_fire_phasers := true
var missile_damage := 50.0
var missile_cooldown_time := 1.0
var _can_fire_missiles := true
var shield_health := 100.0 :
	set(value):
		if value >= 0.0 and value <= max_shield_health:
			shield_health = value
var max_shield_health := 100.0
var _shields_up := false
var shield_fuel_cost := 5
var shield_recovery_rate := 10.0
var shield_percent_absorption := 0.9

@onready var _phaser_area : Area3D = $PhaserArea


func _physics_process(delta: float) -> void:
	if index != 0:
		return
	
	if Input.is_action_just_pressed("increase_thrust"):
		_thrust += 1
	if Input.is_action_just_pressed("decrease_thrust"):
		_thrust -= 1
	if Input.is_action_just_pressed("toggle_shields"):
		_shields_up = not _shields_up
	if Input.is_action_just_pressed("fire_missile") and _can_fire_missiles:
		_fire_missile()
	if Input.is_action_pressed("fire_phaser") and _can_fire_phasers:
		_fire_phaser()
	
	var turning := Input.get_axis("right", "left")
	rotate(Vector3.UP, turning * delta * TAU * turn_speed)
	$Camera3D.global_rotation = Vector3(-PI/2, 0.0, 0.0)
	
	_calculate_fuel(delta)
	
	if not _shields_up:
		shield_health += shield_recovery_rate * delta
	
	print("ship ", index, ": fuel ", round(fuel), " health ", round(health))
	
	move_and_collide(Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * delta * speed)


func _calculate_fuel(delta: float) -> void:
	var delta_fuel := fuel_regeneration - _thrust * thrust_fuel_burn_multiplier
	
	if _shields_up:
		delta_fuel -= shield_fuel_cost
	
	if health < max_health and delta_fuel > 0.0:
		var repair_amount := floorf(delta_fuel / repair_fuel_cost)
		health += repair_amount * delta
		delta_fuel -= repair_fuel_cost * repair_amount
	
	fuel += delta_fuel * delta


func _fire_missile() -> void:
	missile_launch_requested.emit(self)
	_can_fire_missiles = false
	await get_tree().create_timer(missile_cooldown_time).timeout
	_can_fire_missiles = true


func _fire_phaser() -> void:
	var targets := _phaser_area.get_overlapping_bodies()
	var target : Node3D = null
	for potential_target in targets:
		if target:
			if target.global_position.distance_squared_to(global_position) < \
					potential_target.global_position.distance_squared_to(global_position):
				target = potential_target
		else:
			target = potential_target
	if target:
		fuel -= phaser_fuel_cost
		target.damage(phaser_damage)
		_can_fire_phasers = false
		await get_tree().create_timer(phaser_cooldown_time).timeout
		_can_fire_phasers = true


func damage(amount: float) -> void:
	if _shields_up:
		shield_health -= amount * shield_percent_absorption
		amount *= 1.0 - shield_percent_absorption
	health -= amount
