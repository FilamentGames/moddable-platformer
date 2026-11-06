extends RefCounted
class_name SaveFactory
## Generates the correct SaveDataHandler class for the current platform

## Returns the WebSaveDataHandler on web, or the DesktopSaveDataHandler on desktop
static func create() -> SaveDataHandler:
	if OS.has_feature("web"):
		print("Web save data handler initialized")
		return WebSaveDataHandler.new()
	print("Desktop save data handler initialized")
	return DesktopSaveDataHandler.new()