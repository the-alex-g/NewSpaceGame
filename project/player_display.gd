extends Control

signal missile_launch_requested(player: Player)

var player_index := -1 : set = set_player_index, get = get_player_index

@onready var _player := %Player
@onready var _health_bar := %HealthBar
@onready var _fuel_bar := %FuelBar
@onready var _shield_bar := %ShieldBar
@onready var _thrust_label := %ThrustLabel


func set_player_index(value: int) -> void:
	_player.index = value


func get_player_index() -> int:
	return _player.index


func _on_player_missile_launch_requested(player: Player) -> void:
	missile_launch_requested.emit(player)


func _on_player_fuel_updated(fuel: float) -> void:
	_fuel_bar.value = fuel


func _on_player_health_updated(health: float) -> void:
	_health_bar.value = health


func _on_player_shield_strength_updated(shield_strength: float) -> void:
	_shield_bar.value = shield_strength


func _on_player_thrust_updated(thrust: float) -> void:
	_thrust_label.text = "Thrust: %d" % thrust
