extends Control

signal missile_launch_requested(player: Player)

var player_index := -1 : set = set_player_index, get = get_player_index

@onready var _player := %Player


func set_player_index(value: int) -> void:
	_player.index = value


func get_player_index() -> int:
	return _player.index


func _on_player_missile_launch_requested(player: Player) -> void:
	missile_launch_requested.emit(player)
