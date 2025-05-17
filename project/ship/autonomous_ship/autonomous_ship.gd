extends Ship

var _turn_direction := 0

@onready var _detection_area := $DetectionRange
@onready var _shield_drop_timer := $ShieldDropTimer


func _ready() -> void:
	super._ready()
	_thrust = 2


func _act(delta: float) -> void:
	var target := _get_target_in_area(_detection_area)
	if target is Player:
		var distance_to_target := global_position.distance_to(target.global_position)
		var angle := _get_angle_between(global_position, target.global_position) - rotation.y
		angle = fmod(angle + PI, TAU) - PI
		if abs(angle) > PI / 18:
			if _turn_direction == 0:
				_thrust = 1
				if angle > 0.0:
					_turn_direction = 1
				else:
					_turn_direction = -1
		else:
			_turn_direction = 0
			if distance_to_target > 20.0:
				_thrust += 1
			elif distance_to_target < 10.0:
				_thrust -= 1
			if _can_fire_missiles:
				_fire_missile()
		
		_modulate_thrust()
		
		if distance_to_target < 10.0 and _can_fire_phasers:
			_fire_phaser()
		
		if _shields_up and not _shields_should_be_up():
			_shields_up = false
		
		rotate(Vector3.UP, delta * TAU * turn_speed * _turn_direction)
	else:
		_thrust = 2


func _shields_should_be_up() -> bool:
	return health < max_health / 4 or shield_health > max_shield_health / 10.0 or fuel > max_fuel / 4


func _get_angle_between(a: Vector3, b: Vector3) -> float:
	var dx := a.z - b.z
	var dy := a.x - b.x
	return atan2(dy, dx)


func _modulate_thrust() -> void:
	if _thrust < 1 or health < max_health / 10 or fuel < max_fuel / 10:
		_thrust = 1
	elif _shields_up and fuel < max_fuel / 2:
		_thrust = 2
	elif fuel < max_fuel / 2:
		_thrust = 4


func damage(amount: float) -> void:
	super.damage(amount)
	if _shields_should_be_up() and not _shields_up:
		_shields_up = true


func _on_shield_drop_timer_timeout() -> void:
	_shields_up = false


func _set_shields_up(value: bool) -> void:
	super._set_shields_up(value)
	if value:
		_shield_drop_timer.start(10.0)
	else:
		_shield_drop_timer.stop()
