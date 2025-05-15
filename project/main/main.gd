extends Node3D

@onready var _player_display_container := $PlayerDisplayContainer


func add_players(count: int) -> void:
	_player_display_container.columns = ceilf(sqrt(count))
	for x in count:
		_add_player(x)


func _add_player(index: int) -> void:
	var player_display := preload("res://player_display.tscn").instantiate()
	_player_display_container.add_child(player_display)
	player_display.player_index = index
