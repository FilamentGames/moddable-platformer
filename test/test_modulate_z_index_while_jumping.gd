extends BabyGodotTest

var player: CharacterBody2D
var component: ModulateZIndexWhileJumping

func before_each():
	player = autofree(CharacterBody2D.new())
	component = autofree(ModulateZIndexWhileJumping.new())
	component.player = player
	add_child(player)

func test_it_modulates_the_z_index_while_jumping():
	player.z_index = 0
	player.add_child(component)
	player.velocity = Vector2.UP
	component._process(1)

	assert_eq(player.z_index, 1)

	player.velocity = Vector2.DOWN
	component._process(1)

	assert_eq(player.z_index, 0)

	player.velocity = Vector2.ZERO
	component._process(1)

	assert_eq(player.z_index, 0)

func test_it_applies_relative_changes_to_the_z_index():
	player.z_index = 67
	player.add_child(component)
	player.velocity = Vector2.UP
	component._process(1)

	assert_eq(player.z_index, 68)

	player.velocity = Vector2.DOWN
	component._process(1)

	assert_eq(player.z_index, 67)

func test_it_can_customize_the_z_index_offset():
	component.z_index_offset = 10
	player.z_index = 0
	player.add_child(component)
	player.velocity = Vector2.UP
	component._process(1)

	assert_eq(player.z_index, 10)

	player.velocity = Vector2.ZERO
	component._process(1)

	assert_eq(player.z_index, 0)