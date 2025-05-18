class_name Player
extends Ship

signal fuel_updated(fuel: float)
signal health_updated(health: float)
signal shield_strength_updated(shield_strength: float)
signal thrust_updated(thrust: float)

var index := 0


func _ready() -> void:
	$ShieldMesh.set_instance_shader_parameter("y_threshold", 0.0)


func _act(delta: float) -> void:
	if Input.is_action_just_pressed("increase_thrust_%d" % index):
		_thrust += 1
	if Input.is_action_just_pressed("decrease_thrust_%d" % index):
		_thrust -= 1
	if Input.is_action_just_pressed("toggle_shields_%d" % index):
		_shields_up = not _shields_up
	if Input.is_action_pressed("fire_missile_%d" % index) and _can_fire_missiles:
		_fire_missile()
	if Input.is_action_pressed("fire_phaser_%d" % index) and _can_fire_phasers:
		_fire_phaser()
	
	var turning := -Input.get_joy_axis(index, JOY_AXIS_LEFT_X)
	if index == 0:
		turning += Input.get_axis("right", "left")
	rotate(Vector3.UP, turning * delta * TAU * turn_speed)


func set_fuel(value: float) -> void:
	super.set_fuel(value)
	fuel_updated.emit(fuel)


func set_shield_health(value: float) -> void:
	super.set_shield_health(value)
	shield_strength_updated.emit(shield_health)


func set_health(value: float) -> void:
	super.set_health(value)
	health_updated.emit(health)


func _set_thrust(value: int) -> void:
	super._set_thrust(value)
	thrust_updated.emit(_thrust)
