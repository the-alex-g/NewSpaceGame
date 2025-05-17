extends GridContainer

@export var initial_players := 1


func _ready() -> void:
	add_players(initial_players)


func add_players(count: int) -> void:
	columns = ceili(sqrt(count))
	for x in count:
		_add_player(x)
	for child_1 in get_children():
		for child_2 in get_children():
			child_1.track_object(child_2.get_player())


func _add_player(index: int) -> void:
	var player_display := preload("res://player_display.tscn").instantiate()
	add_child(player_display)
	player_display.player_index = index
	player_display.missile_launch_requested.connect(get_parent().on_player_missile_launch_requested)
