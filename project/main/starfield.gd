class_name StarField
extends MultiMeshInstance3D

@export var near := 300.0
@export var far := 700.0
@export var size := 500.0
@export var star_count := 4000
@export var min_star_radius := 2.0
@export var max_star_radius := 10.0
@export var star_radius_curve := Curve.new()
@export var star_color_gradient := Gradient.new()


func _ready()->void:
	multimesh = MultiMesh.new()
	multimesh.use_colors = true
	var mesh := SphereMesh.new()
	mesh.material = _get_material()
	multimesh.mesh = mesh
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	generate()


func generate()->void:
	multimesh.instance_count = star_count
	for i in star_count:
		var weight := star_radius_curve.sample(randf())
		multimesh.set_instance_color(i, star_color_gradient.sample(weight))
		
		multimesh.set_instance_transform(i, Transform3D(
			Basis.from_scale(Vector3.ONE * lerpf(min_star_radius, max_star_radius, weight)),
			Vector3(
				lerpf(-size, size, randf()) / 2,
				lerpf(-near, -far, randf()),
				lerpf(-size, size, randf()) / 2
			)
		))


func _get_material()->StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.albedo_color = Color.WHITE
	return material
