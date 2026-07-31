extends GutTest

func _get_size(builtin_size: Vector2, window_size: Vector2) -> Vector2:
	return Hud2._get_scaled_viewport_size(builtin_size, window_size)

func test_if_window_is_same_size_as_builtin_size_it_does_nothing():
	assert_eq(_get_size(Vector2(1920, 1080), Vector2(1920, 1080)), Vector2(1920, 1080))

func test_if_window_is_same_aspect_ratio_as_builtin_size_it_scales_perfectly():
	assert_eq(_get_size(Vector2(1920, 1080), Vector2(1920, 1080) / 2), Vector2(960, 540))

func test_if_window_is_different_aspect_ratio_it_scales_to_fit():
	assert_eq(_get_size(Vector2(1920, 1080), Vector2(1080, 1920)), Vector2(1080, 1080.0 / (1920.0 / 1080.0)))
	assert_eq(_get_size(Vector2(1920, 1080), Vector2(1920, 1000)), Vector2(1000.0 * (1920.0 / 1080.0), 1000.0))
	assert_ne(_get_size(Vector2(1280, 720), Vector2(1160, 720)), Vector2(1280, 720))