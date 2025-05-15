extends GridContainer


func _ready() -> void:
	add_players(2)


func add_players(count: int) -> void:
	columns = ceilf(sqrt(count))
	for x in count:
		_add_player(x)


func _add_player(index: int) -> void:
	var player_display := preload("res://player_display.tscn").instantiate()
	add_child(player_display)
	player_display.player_index = index
	player_display.missile_launch_requested.connect(get_parent().on_player_missile_launch_requested)
