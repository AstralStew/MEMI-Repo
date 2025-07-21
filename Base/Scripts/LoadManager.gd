extends Node

#var HOST_URL := "https://www.paperticketstudios.com/godot/projectmemi/"

signal request_started()

signal request_successful()
signal request_successful_with(file)
signal request_skipped()
signal request_skipped_with(file)
signal request_failed()
signal request_failed_with(file)
signal request_error()
signal request_error_with(file)

var filename := ""
var hostURL = "" 
var packsURL = "" 
var audioURL = ""

func _set_paths():
	print("[LoadManager] Setting hostURL, packsURL, audioURL for the first time.")
	hostURL = BridgeManager.folderURL
	packsURL = hostURL + "Packs/"
	audioURL = hostURL + "Audio/"


func _load_mp3(filename:StringName):
	if hostURL == "": _set_paths()
	
	var file = FileAccess.open(audioURL + filename, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound



func _load_pack(_filename:String):
	if hostURL == "": _set_paths()
	
	request_started.emit()
	
	# Check if we've already tried _filename with a previous HTTPRequest
	for child in get_children():
		if child.name.contains(_filename):
			print("[LoadManager] Pack '",_filename,"' has already been requested, ignoring.")
			request_skipped.emit()
			request_skipped_with.emit(_filename)
			return
	
	filename = _filename + ".pck"
	
	print("[LoadManager] Attempting HTTP request for '",packsURL+filename,"'...")
	
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.name += " {"+filename+"}"
	http_request.request_completed.connect(self._http_request_completed_callback)
	
	var error = http_request.request(packsURL+filename)
	if error != OK:
		push_error("[HTTPLoader] An error occurred in the HTTP request for '",packsURL+filename,"'")
		request_error.emit()
		request_error_with.emit(filename)

func _http_request_completed_callback(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		# Write the PCK data to a temporary file
		var temp_path = "res://" + filename # Note "user://mod.pck" also works
		var file = FileAccess.open(temp_path, FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		# Load the resource pack
		var success = ProjectSettings.load_resource_pack(temp_path)

		if success:
			print("[HTTPLoader] Packed asset loaded successfully from '",packsURL+filename,"'")
			request_successful.emit()
			request_successful_with.emit(filename)
		else:
			print("[HTTPLoader] Failed to load packed asset from '",packsURL+filename,"'")
			request_failed.emit()
			request_failed_with.emit(filename)
	else:
		push_error("[HTTPLoader] HTTP request from '",packsURL+filename,"' failed with response code: ", response_code)
		request_error.emit()
		request_error_with.emit(filename)
