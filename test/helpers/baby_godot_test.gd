extends GutTest
class_name BabyGodotTest
## Subclass of `GutTest` with shared helper methods

## Creates a new autofreed `CallableSpy`. Shortcut for nicer type inferenced code.
func create_spy() -> CallableSpy:
	return autofree(CallableSpy.new())