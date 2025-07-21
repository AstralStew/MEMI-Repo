extends Node

@export var filename := "mod.pck"
@export var hostURL := "https://your.server.com/path/to/"

signal request_successful()
signal request_successful_with(file)
signal request_failed()
signal request_failed_with(file)
signal request_error()
signal request_error_with(file)

func _ready():
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	var error = http_request.request(hostURL + filename)
	if error != OK:
		push_error("[HTTPLoader] An error occurred in the HTTP request for '",hostURL+filename,"'")
		request_error.emit()
		request_error_with.emit(filename)



func _http_request_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		# Write the PCK data to a temporary file
		var temp_path = "res://" + filename # Note "user://mod.pck" also works
		var file = FileAccess.open(temp_path, FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		# Load the resource pack
		var success = ProjectSettings.load_resource_pack(temp_path)

		if success:
			print("[HTTPLoader] Packed asset loaded successfully from '",hostURL+filename,"'")
			request_successful.emit()
			request_successful_with.emit(filename)
		else:
			print("[HTTPLoader] Failed to load packed asset from '",hostURL+filename,"'")
			request_failed.emit()
			request_failed_with.emit(filename)
	else:
		push_error("[HTTPLoader] HTTP request from '",hostURL+filename,"' failed with response code: ", response_code)
		request_error.emit()
		request_error_with.emit(filename)


## Now you can use the assets from the resource pack
			#var imported_scene: PackedScene = load("res://mod_scene.tscn")
			## Create an instance of the PackedScene
			#var instance = imported_scene.instantiate()
			## Add the instance to the scene tree
			#add_child(instance)
