@tool
extends RigidBody3D

@export_tool_button("generate asteroid") var initialize_asteroid_action := _initialize_asteroid
@export var radius := 0.0


func _ready() -> void:
	_initialize_asteroid()


func _initialize_asteroid() -> void:
	if radius == 0.0:
		radius = lerp(1.0, 4.0, randf())
	_size_collision_shape(_initialize_asteroid_shader())


func _initialize_asteroid_shader() -> Vector3:
	var asteroid_scale := Vector3(lerpf(0.25, 1.0, randf()), 0.75, lerpf(0.25, 1.0, randf())) * radius
	$MeshInstance3D.set_instance_shader_parameter("scale", asteroid_scale)
	$MeshInstance3D.set_instance_shader_parameter(
		"noise_offset",
		Vector2(
			lerpf(0.0, 511.0, randf()),
			lerpf(0.0, 511.0, randf())
		)
	)
	
	return asteroid_scale


func _size_collision_shape(dimensions: Vector3) -> void:
	var shape := BoxShape3D.new()
	shape.size = dimensions
	$CollisionShape3D.shape = shape


func damage(_amount: float) -> void:
	queue_free()
	if radius > 1.0:
		for x in roundi(lerpf(1.0, radius, randf())):
			_spawn_child_asteroid()


func _spawn_child_asteroid() -> void:
	var asteroid := preload("res://asteroid/asteroid.tscn").instantiate()
	asteroid.radius = radius / 2.0
	get_parent().add_child(asteroid)
	var offset_direction := Vector3.FORWARD.rotated(Vector3.UP, TAU * randf())
	asteroid.global_position = global_position + offset_direction * radius
	asteroid.apply_central_impulse(offset_direction * lerpf(1.0, 3.0, randf()))
