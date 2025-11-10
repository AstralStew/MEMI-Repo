extends Node


# Get the `window` object, where globally defined functions are
var window = null # JavaScriptBridge.get_interface("window")

# Get the `recognition` object defined in the header
var recognition = null # JavaScriptBridge.get_interface("recognition")

# Get the `pageURL` object defined in the header
var pageURL : String = ""
@onready var folderURL : String = ""

# Here we create a reference to the functions below
# These references will be kept until the node is freed.
var _speech_result_callback_ref = JavaScriptBridge.create_callback(_on_speech_result_callback)
var _speech_end_callback_ref = JavaScriptBridge.create_callback(_on_speech_end_callback)
var _speech_nomatch_callback_ref = JavaScriptBridge.create_callback(_on_speech_nomatch_callback)
var _speech_error_callback_ref = JavaScriptBridge.create_callback(_on_speech_error_callback)

var _audio_start_callback_ref = JavaScriptBridge.create_callback(_on_audio_start_callback)
var _audio_end_callback_ref = JavaScriptBridge.create_callback(_on_audio_end_callback)
var _sound_start_callback_ref = JavaScriptBridge.create_callback(_on_sound_start_callback)
var _sound_end_callback_ref = JavaScriptBridge.create_callback(_on_sound_end_callback)

# These signals tell objects what transpired from the callbacks above
signal speech_start()
signal speech_phrase(phrase)
signal speech_nomatch()
signal speech_end()
signal speech_error()

signal speech_audiostart()
signal speech_audioend()
signal speech_soundstart()
signal speech_soundend()

# Called in ScreenController _ready()
func _initialise() -> void:
	
	window = JavaScriptBridge.get_interface("window")
	recognition = JavaScriptBridge.get_interface("recognition")
	
	print("[BridgeManager] window = '", window,"', recognition ='", recognition,"'")
	recognition.onresult = _speech_result_callback_ref
	recognition.onspeechend = _speech_end_callback_ref
	recognition.onnomatch = _speech_nomatch_callback_ref
	recognition.onerror = _speech_error_callback_ref
	
	recognition.onaudiostart = _audio_start_callback_ref
	recognition.onaudioend = _audio_end_callback_ref
	recognition.onsoundstart = _sound_start_callback_ref
	recognition.onsoundend = _sound_end_callback_ref

	pageURL = JavaScriptBridge.eval("pageURL;")
	folderURL = JavaScriptBridge.eval("folderURL;")
	print("[BridgeManager] PageURL = ",pageURL," , FolderURL = ",folderURL)	
	
	





func _test_javascript() -> void:
	print("[BridgeManager] Testing javascript...")
	# Direct way of doing calls
	JavaScriptBridge.eval("""alert("Hello from Godot!") """);

#
#func _test_A_callback(_args) -> void:
	#var num = 0
	#for arg in _args:
		#print("[TEST A] arg #",num," =",arg)
		#num += 1
	## Get the first argument
	#var js_event = _args[0]
	#print("[TEST A] js_event = ",js_event)
	#
#
#func _test_B_callback(_args) -> void:
	#var num = 0
	#for arg in _args:
		#print("[TEST B] arg #",num," =",arg)
		#num += 1
	## Get the first argument
	#var js_event = _args[0]
	#print("[TEST B] js_event = ",js_event)

func initial_load_finished() -> void:
	print("[BridgeManager] Subscibing to LoadingStarted and LoadingFinished (for pck loading screen)")
	
	window.initialLoadFinished()
	
	await get_tree().process_frame
	
	# Setup loading requests for pcks
	LoadManager.request_started.connect(loading_started)
	LoadManager.request_error.connect(loading_finished)
	LoadManager.request_failed.connect(loading_finished)
	LoadManager.request_successful.connect(loading_finished)

func loading_started() -> void:
	print("[BridgeManager] Announcing that we're loading stuff...")
	window.loadingStarted()

func loading_finished() -> void:
	print("[BridgeManager] Announcing that we've finished loading stuff...")
	window.loadingFinished()

func exit_normal() -> void:
	print("[BridgeManager] Announcing that we wanna exit...")
	window.exitNormal()

func exit_quick() -> void:
	print("[BridgeManager] Announcing that we wanna exit quickly...")
	window.exitQuick()

func share_experience() -> void:
	print("[BridgeManager] Announcing that we wanna share the experience...")
	window.shareExperience()




func _start_recognition() -> void:	
	print("[BridgeManager] Attempting to start recognition...")
	# Call the JavaScript `startRecognition` function defined in the custom HTML head
	window.startRecognition()
	
	print("[BridgeManager] On Speech Start callback!")
	speech_start.emit()

func _stop_recognition() -> void:
	window.stopRecognition()

func _on_speech_result_callback(_args):
	#print("[BridgeManager] On Speech Result callback...")
	#var js_event = _args[0]
	#var phrase = js_event.results[0][0].transcript;
	##var confidence = js_event.results[0][0].confidence;
	#print("[BridgeManager] Phrase received: ", phrase)
	#speech_phrase.emit(phrase)
	print("[BridgeManager] On Speech Result callback...")
	
	await get_tree().process_frame
	
	var js_results = """
	function getLastResult() {
		return lastResult;
	}
	getLastResult();
	"""
	
	var last_result = JavaScriptBridge.eval(js_results)
	print("[BridgeManager] Last Result = ", last_result)
	#for phrase in last_results.split("|"):
	#	print("[BridgeManager] Phrase received: ", phrase)
	
	speech_phrase.emit(last_result)




func _on_speech_end_callback(_args):
	print("[BridgeManager] On Speech End callback! Waiting for speech_ongoing...")
	var speech_ongoing = true
	var js_results = ""
	while(speech_ongoing):
		await get_tree().process_frame
		js_results = """
		function getSpeechOngoing() {
		return speech_ongoing;
		}
		getSpeechOngoing();
		"""
		speech_ongoing = JavaScriptBridge.eval(js_results)
	print("[BridgeManager] Finished speech_ongoing! Emitting end.")
	speech_end.emit()

func _on_speech_nomatch_callback(_args):
	# Don't think we'll ever get this
	# NOPE I stand corrected, this should be an error
	print("[BridgeManager] On Speech No Match callback!")
	speech_nomatch.emit()

func _on_speech_error_callback(_args):
	print("[BridgeManager] On Speech Error callback...")
	var js_event = _args[0]
	var error = js_event.error;
	var message = js_event.message;
	print("[BridgeManager] Error Type: '", error,"', message = '",message,"'")
	speech_error.emit()

func _on_audio_start_callback(_args):
	print("[BridgeManager] On Audio Start callback.")
	speech_audiostart.emit()

func _on_audio_end_callback(_args):
	print("[BridgeManager] On Audio End callback.")
	speech_audioend.emit()

func _on_sound_start_callback(_args):
	print("[BridgeManager] On Sound Start callback.")
	speech_soundstart.emit()

func _on_sound_end_callback(_args):
	print("[BridgeManager] On Sound End callback.")
	speech_soundend.emit()
