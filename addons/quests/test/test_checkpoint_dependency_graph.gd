extends BabyGodotTest

var graph: CheckpointDependencyGraph

func before_each():
	graph = CheckpointDependencyGraph.new()

func test_it_can_sort_an_empty_graph():
	assert_eq(graph.get_sorted_values().size(), 0, "get_sorted_values returns an empty array for an empty graph")

func test_it_can_sort_a_graph_with_no_dependencies():
	graph.add_vertex(CheckpointDependencyGraph.Vertex.create(1))

	assert_eq(graph.get_sorted_values(), [1])

func test_it_can_sort_a_graph_with_dependencies():
	var vert1 = CheckpointDependencyGraph.Vertex.create(1)
	var vert2 = CheckpointDependencyGraph.Vertex.create(2)
	vert2.add_dependency(vert1)

	graph.add_vertex(vert2)
	graph.add_vertex(vert1)

	assert_eq(graph.get_sorted_values(), [1, 2])

func test_it_can_sort_a_graph_with_complex_dependencies():
	var vert1 = CheckpointDependencyGraph.Vertex.create(1)
	var vert2 = CheckpointDependencyGraph.Vertex.create(2)
	var vert3 = CheckpointDependencyGraph.Vertex.create(3)
	var vert4 = CheckpointDependencyGraph.Vertex.create(4)

	vert2.add_dependency(vert1)
	vert3.add_dependency(vert4)
	vert3.add_dependency(vert2)
	vert4.add_dependency(vert1)

	graph.add_vertex(vert1)
	graph.add_vertex(vert2)
	graph.add_vertex(vert3)
	graph.add_vertex(vert4)
	
	assert_eq(graph.get_sorted_values(), [1, 2, 4, 3])
