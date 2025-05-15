class_name Missile
extends CharacterBody3D

var damage := 0.0
var speed := 175


func _physics_process(delta: float) -> void:
	move_and_collide(Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * speed * delta)


func _on_timer_timeout() -> void:
	queue_free()
