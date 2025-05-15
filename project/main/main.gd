extends Node3D

@onready var _missile_container := $MissileContainer


func on_player_missile_launch_requested(player: Player) -> void:
	var missile = load("res://missile/missile.tscn").instantiate()
	_missile_container.add_child(missile)
	missile.global_position = player.global_position + \
		Vector3.DOWN * 3 + \
		Vector3.FORWARD.rotated(Vector3.UP, player.rotation.y) * player.speed / 100
	missile.rotation = player.rotation
	missile.damage = player.missile_damage
