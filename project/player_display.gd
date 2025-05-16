extends Control

signal missile_launch_requested(player: Player)

const ACTIONS := {
	"increase_thrust":JOY_BUTTON_RIGHT_SHOULDER,
	"decrease_thrust":JOY_BUTTON_LEFT_SHOULDER,
	"toggle_shields":JOY_BUTTON_A,
	"fire_phaser":JOY_BUTTON_X,
	"fire_missile":JOY_BUTTON_Y
}

var player_index := -1 : set = set_player_index, get = get_player_index

@onready var _player := %Player
@onready var _health_bar := %HealthBar
@onready var _fuel_bar := %FuelBar
@onready var _shield_bar := %ShieldBar
@onready var _thrust_label := %ThrustLabel
@onready var _radar := $Radar
@onready var _camera := $SubViewportContainer/SubViewport/Camera3D
@onready var _camera_offset : Vector3 = _camera.position


func _ready() -> void:
	_radar.central_object = _player


func _process(_delta: float) -> void:
	_camera.position = _player.position + _camera_offset


func set_player_index(value: int) -> void:
	_player.index = value
	_player.position += Vector3.FORWARD.rotated(Vector3.UP, PI * player_index / 2) * 3
	_initialize_player_controls(value)


func get_player_index() -> int:
	return _player.index


func get_player() -> Player:
	return _player


func track_object(object: Node3D) -> void:
	if object != _player:
		_radar.track_object(object)


func _initialize_player_controls(index: int) -> void:
	for action in ACTIONS:
		var action_name := "%s_%d" % [action, index]
		if index != 0:
			InputMap.add_action(action_name)
		var event := InputEventJoypadButton.new()
		event.button_index = ACTIONS[action]
		event.device = index
		InputMap.action_add_event(action_name, event)


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
