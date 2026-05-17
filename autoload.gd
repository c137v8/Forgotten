# ApiManager.gd
extends Node

var api_key: String = ""

func _ready():
	load_keys()

func load_keys():
	var config = ConfigFile.new()
	var path := "res://api_keys.cfg"
	
	if not File.new().file_exists(path):
		push_error("api_keys.cfg not found! Copy from api_keys.cfg.example")
		return
	
	if config.load(path) == OK:
		api_key = config.get_value("API", "key", "")
		if api_key.empty():
			push_warning("API key is empty!")
	else:
		push_error("Failed to load api_keys.cfg")

func get_key() -> String:
	return api_key
