extends RefCounted
class_name CheckpointDependencyGraph
## Helper class to resolve dependencies in a checkpoint's watched nodes list.

## Represents a vertex in a graph
class Vertex extends RefCounted:
	var value: Variant
	var dependencies: Array[Vertex] = []
	var dependents: Array[Vertex] = []

	func add_dependency(dependency: Vertex) -> void:
		if not dependency:
			return
		dependencies.push_back(dependency)
		dependency.dependents.push_back(self)
	
	static func create(val: Variant) -> Vertex:
		var v = Vertex.new()
		v.value = val
		return v

var vertices: Array[Vertex] = []

func add_vertex(vert: Vertex) -> void:
	vertices.push_back(vert)

func get_vertex(value: Variant) -> Vertex:
	var index := vertices.find_custom(func(vert: Vertex):
		return str(vert.value) == str(value)
	)
	if index == -1:
		return null
	return vertices[index]

func _has_no_edges(vert: Vertex) -> bool:
	return vert.dependencies.size() == 0

## Returns a topologically sorted list of the values in our dependency graph. [br]
## This function destroys the graph as part of its sorting algorithm so it may only be used once per graph.
func get_sorted_values() -> Array:
	var edgeless_vertices: Array[Vertex] = []
	var result: Array[Variant] = []
	edgeless_vertices = vertices.filter(_has_no_edges)

	# Implementation of Kahn's Algorithm
	# See: https://en.wikipedia.org/wiki/Topological_sorting#Kahn's_algorithm
	while not edgeless_vertices.is_empty():
		var vertex: Vertex = edgeless_vertices.pop_front()
		result.push_back(vertex.value)
		for dependent in vertex.dependents:
			dependent.dependencies.erase(vertex)
			if dependent.dependencies.size() == 0:
				edgeless_vertices.push_back(dependent)

	vertices.clear()

	return result
