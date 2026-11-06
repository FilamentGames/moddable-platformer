extends SaveDataHandler
class_name WebSaveDataHandler
## The save data handler that is used in web builds

const SAVE_DATA_KEY := "save_data"

func _get_web_storage() -> JavaScriptObject:
	return JavaScriptBridge.get_interface("window").localStorage

func _write_json(data: String) -> void:
	_get_web_storage().setItem(SAVE_DATA_KEY, data)

func _fetch_data() -> String:
	return _get_web_storage().getItem(SAVE_DATA_KEY)

func clear_data() -> void:
	_get_web_storage().removeItem(SAVE_DATA_KEY)