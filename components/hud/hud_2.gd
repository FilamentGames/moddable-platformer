extends CanvasLayer
class_name Hud2

func _ready():
	_keep_scale_constant()
	get_tree().root.size_changed.connect(_keep_scale_constant)

func _keep_scale_constant() -> void:
	## Make it the same size regardless of scale factor
	var builtin_size := Vector2(get_window().content_scale_size)	
	var window_scale := _get_scaled_viewport_size(builtin_size, Vector2(get_viewport().size)) / builtin_size
	var ui_scale := Vector2.ONE / window_scale
	var children := get_children()
	for child in children:
		if "scale" in child:
			child.scale = ui_scale
			child.queue_redraw()

static func _get_scaled_viewport_size(builtin_size: Vector2, window_size: Vector2) -> Vector2:
	var aspect := builtin_size.x / builtin_size.y
	if window_size.x / window_size.y > aspect:
		return Vector2(window_size.y * aspect, window_size.y)
	return Vector2(window_size.x, window_size.x / aspect)
