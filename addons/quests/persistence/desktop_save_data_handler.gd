extends SaveDataHandler
class_name DesktopSaveDataHandler
## The desktop implementation for the save data handler. This is mainly used for development testing right now, as the web save data handler is used in production builds right now.

const SAVE_DATA_PATH := "user://save_data.json"

func _write_json(data: String) -> void:
	var file := FileAccess.open(SAVE_DATA_PATH, FileAccess.WRITE)
	file.store_string(data)

func _fetch_data() -> String:
	if not FileAccess.file_exists(SAVE_DATA_PATH):
		return ""
	var file := FileAccess.open(SAVE_DATA_PATH, FileAccess.READ)
	var contents := file.get_as_text()
	return contents

func clear_data() -> void:
	DirAccess.remove_absolute(SAVE_DATA_PATH)