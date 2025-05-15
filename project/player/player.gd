extends CharacterBody3D

@export var turn_speed := 0.5

var index := 0
var _thrust := 0 :
	set(value):
		if value <= 6 and value >= 0:
			_thrust = value


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("increase_thrust"):
		_thrust += 1
	if Input.is_action_just_pressed("decrease_thrust"):
		_thrust -= 1
	
	var turning := Input.get_axis("right", "left")
	rotate(Vector3.UP, turning * delta * TAU * turn_speed)
	$Camera3D.global_rotation = Vector3(-PI/2, 0.0, 0.0)
	
	move_and_collide(Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * delta * _thrust * 50)
