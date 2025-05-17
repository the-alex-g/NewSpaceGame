class_name Missile
extends CharacterBody3D

var missile_damage := 0.0
var speed := 20
var launcher : Ship


func _physics_process(delta: float) -> void:
	move_and_collide(Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * speed * delta)


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body == launcher and not body == self:
		body.damage(missile_damage)
		queue_free()


func damage(_amount: float) -> void:
	queue_free()
