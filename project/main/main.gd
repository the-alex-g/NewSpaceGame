extends Node3D

@onready var _missile_container := $MissileContainer


func on_player_missile_launch_requested(player: Player) -> void:
	var missile = load("res://missile/missile.tscn").instantiate()
	_missile_container.add_child(missile)
	missile.launcher = player
	missile.global_position = player.global_position + player.missile_drop_offset
	missile.rotation = player.rotation
	missile.damage = player.missile_damage
