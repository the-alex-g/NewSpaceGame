class_name Ship
extends CharacterBody3D

const FRICTION := 2.0

@export var turn_speed := 0.5

var _thrust := 0 : set = _set_thrust, get = _get_thrust
@export_group("thrust and fuel")
@export var max_thrust := 6
@export var max_fuel := 100.0
@export var fuel_regeneration := 10.0
@export var thrust_fuel_burn_multiplier := 2.5
@export var thrust_speed_multiplier := 2.0 :
	get():
		return thrust_speed_multiplier + FRICTION
@export_group("health")
@export var max_health := 100.0
@export var repair_fuel_cost := 2.0
@export_group("phasers")
@export var phaser_fuel_cost := 5
@export var max_phaser_damage := 10.0
@export var min_phaser_damage := 2.5
@export var phaser_cooldown_time := 0.5
@export_group("missiles")
@export var missile_damage := 50.0
@export var missile_cooldown_time := 1.0
@export_group("shields")
@export var max_shield_health := 100.0
@export var shield_fuel_cost := 5
@export var shield_recovery_rate := 10.0
@export var shield_percent_absorption := 0.9

var speed : float :
	get():
		return _thrust * thrust_speed_multiplier
var _can_fire_phasers := true :
	get():
		return _can_fire_phasers and fuel >= phaser_fuel_cost
var _can_fire_missiles := true
var _shields_up := false : set = _set_shields_up

@onready var _phaser_area : Area3D = $PhaserArea
@onready var _animation_player : AnimationPlayer = $AnimationPlayer
@onready var missile_drop_offset : Vector3 = $MissileDropLocation.position :
	get():
		return missile_drop_offset + _get_forward_vector() * speed / 100.0
@onready var fuel := max_fuel : set = set_fuel
@onready var health := max_health : set = set_health
@onready var shield_health := max_shield_health : set = set_shield_health


func _ready() -> void:
	$ShieldMesh.set_instance_shader_parameter("y_threshold", 0.0)


func _physics_process(delta: float) -> void:
	_calculate_fuel(delta)
	
	shield_health += shield_recovery_rate * delta * (0.25 if _shields_up else 1.0)
	
	_act(delta)
	
	velocity += (speed * _get_forward_vector() - velocity * FRICTION) * delta
	
	if move_and_slide():
		damage(25.0 * delta * (_thrust + 1))


func _act(_delta: float) -> void:
	pass


func _get_forward_vector() -> Vector3:
	return Vector3.FORWARD.rotated(Vector3.UP, rotation.y)


func _get_cruising_speed() -> int:
	return floori((fuel_regeneration - (shield_fuel_cost if _shields_up else 0)) / \
		thrust_fuel_burn_multiplier)


func _calculate_fuel(delta: float) -> void:
	var delta_fuel := fuel_regeneration - _thrust * thrust_fuel_burn_multiplier
	
	if _shields_up:
		delta_fuel -= shield_fuel_cost
	
	var repair_amount := 1.0
	if health < max_health and delta_fuel > 0.0 and \
			(health < max_health / 2.0 or fuel > max_fuel / 1.5):
		repair_amount = maxf(1.0, floorf(delta_fuel / repair_fuel_cost)) 
		delta_fuel -= repair_fuel_cost * repair_amount
	health += repair_amount * delta
	
	fuel += delta_fuel * delta


func _fire_missile() -> void:
	var missile = load("res://missile/missile.tscn").instantiate()
	get_tree().root.add_child(missile)
	missile.launcher = self
	missile.global_position = global_position + missile_drop_offset
	missile.rotation.y = _get_missile_launch_angle()
	missile.missile_damage = missile_damage
	_can_fire_missiles = false
	await get_tree().create_timer(missile_cooldown_time).timeout
	_can_fire_missiles = true


func _get_missile_launch_angle() -> float:
	return rotation.y


func _fire_phaser() -> void:
	var target := _get_target_in_area(_phaser_area)
	if target:
		fuel -= phaser_fuel_cost
		target.damage(lerp(
			max_phaser_damage,
			min_phaser_damage,
			pow(target.global_position.distance_to(global_position) / 10.0, 2.0)
		))
		_spawn_phaser_beam(target)
		_can_fire_phasers = false
		await get_tree().create_timer(phaser_cooldown_time).timeout
		_can_fire_phasers = true


func _get_target_in_area(area: Area3D) -> Node3D:
	var targets := area.get_overlapping_bodies()
	var target : Node3D = null
	for potential_target in targets:
		if potential_target != self:
			if target:
				if target.global_position.distance_squared_to(global_position) < \
						potential_target.global_position.distance_squared_to(global_position):
					target = potential_target
			else:
				target = potential_target
	return target


func _spawn_phaser_beam(target: Node3D) -> void:
	var offset := global_position - target.global_position
	var distance := offset.length()
	var mesh := CylinderMesh.new()
	mesh.height = distance
	mesh.top_radius = 0.1
	mesh.bottom_radius = 0.1
	var mesh_instance := MeshInstance3D.new()
	get_tree().root.add_child(mesh_instance)
	mesh_instance.mesh = mesh
	mesh_instance.global_position = lerp(global_position, target.global_position, 0.5)
	mesh_instance.rotation.y = atan2(-offset.z, offset.x) + PI / 2
	mesh_instance.rotation.x = PI / 2
	create_tween().tween_property(mesh_instance, "global_position", target.global_position, 0.1).set_trans(Tween.TRANS_QUAD)
	await create_tween().tween_property(mesh, "height", 0.2, 0.1).set_trans(Tween.TRANS_QUAD).finished
	mesh_instance.queue_free()


func damage(amount: float) -> void:
	if _shields_up:
		var absorption := minf(shield_health, amount * shield_percent_absorption)
		shield_health -= absorption
		amount -= absorption
	health -= amount


func set_health(value: float) -> void:
	if value < 0.0:
		health = 0.0
	elif value > max_health:
		health = max_health
	else:
		health = value


func set_shield_health(value: float) -> void:
	if value < 0.0:
		shield_health = 0.0
	elif value > max_shield_health:
		shield_health = max_shield_health
	else:
		shield_health = value


func set_fuel(value: float) -> void:
	if value < 0.0:
		fuel = 0.0
	elif value > max_fuel:
		fuel = max_fuel
	else:
		fuel = value


func _set_thrust(value: int) -> void:
	if value < 0:
		_thrust = 0
	elif value > max_thrust:
		_thrust = max_thrust
	else:
		_thrust = value


func _get_thrust() -> int:
	if _thrust * thrust_fuel_burn_multiplier > fuel:
		_thrust = floor(fuel / thrust_fuel_burn_multiplier)
	return _thrust


func _set_shields_up(value: bool) -> void:
	_shields_up = value
	if _shields_up:
		_animation_player.play("shield_up")
	else:
		_animation_player.play_backwards("shield_up")
