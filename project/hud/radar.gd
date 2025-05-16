extends Control

const POINT_RADIUS = 8.0
const POINT_SPACING = 2.0

var objects_to_track : Array[Node3D] = []
var central_object : Node3D

@onready var _radar_circle_radius := minf(size.x, size.y) / 2 - \
	(POINT_RADIUS / 2 + POINT_SPACING)


func track_object(object: Node3D) -> void:
	objects_to_track.append(object)


func _get_pos_2d(vector: Vector3) -> Vector2:
	return -Vector2(vector.x, vector.z)


func _get_offset(object: Node3D) -> Vector2:
	return _get_pos_2d(object.global_position - central_object.global_position) * 20 + size / 2


func _is_visible(object: Node3D) -> bool:
	var offset := _get_offset(object)
	return offset.x > 0.0 and offset.x < size.x and offset.y > 0.0 and offset.y < size.y


func _get_draw_point(object: Node3D) -> Vector2:
	return _get_pos_2d(central_object.global_position - object.global_position).normalized() * _radar_circle_radius + size / 2


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for object in objects_to_track:
		if not _is_visible(object):
			draw_circle(_get_draw_point(object), POINT_RADIUS, Color.WHITE)
