extends BabyGodotTest

var condition: ParentChildRelationshipScrollCondition
var parent: Node
var child: Node
var other: Node

func before_each():
	condition = autofree(ParentChildRelationshipScrollCondition.new())
	parent = autofree(Node.new())
	child = autofree(Node.new())

func test_it_exists():
	assert_not_null(condition)

func test_it_returns_false_if_no_parent_child_relationship():
	condition.parent_node = parent
	condition.child_node = child

	assert_false(condition.is_condition_met())

func test_it_returns_true_if_parent_child_relationship():
	condition.parent_node = parent
	condition.child_node = child
	parent.add_child(child)

	assert_true(condition.is_condition_met())

	condition.parent_node = other

	assert_false(condition.is_condition_met())

func test_fails_gracefully_if_no_parent_or_child_defined():
	assert_false(condition.is_condition_met())