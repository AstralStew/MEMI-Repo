extends Node


# Get the `window` object, where globally defined functions are
@onready var window = JavaScriptBridge.get_interface("window")

# Get the `recognition` object defined in the header
@onready var recognition = JavaScriptBridge.get_interface("recognition")

# Get the `pageURL` object defined in the header
@onready var pageURL : String = ""
@onready var folderURL : String = ""

# Here we create a reference to the functions below
# These references will be kept until the node is freed.
var _speech_result_callback_ref = JavaScriptBridge.create_callback(_on_speech_result_callback)
var _speech_end_callback_ref = JavaScriptBridge.create_callback(_on_speech_end_callback)
var _speech_nomatch_callback_ref = JavaScriptBridge.create_callback(_on_speech_nomatch_callback)
var _speech_error_callback_ref = JavaScriptBridge.create_callback(_on_speech_error_callback)

# These signals tell objects what transpired from the callbacks above
signal speech_start()
signal speech_phrase(phrase)
signal speech_end()
signal speech_error()


# Called in ScreenController _ready()
func _initialise() -> void:
	recognition.onresult = _speech_result_callback_ref
	recognition.onspeechend = _speech_end_callback_ref
	recognition.onnomatch = _speech_nomatch_callback_ref
	recognition.onerror = _speech_error_callback_ref

	pageURL = JavaScriptBridge.eval("pageURL;")
	folderURL = JavaScriptBridge.eval("folderURL;")
	print("[BridgeManager] PageURL = ",pageURL," , FolderURL = ",folderURL)	


func _test_javascript() -> void:	
	print("[BridgeManager] Testing javascript...")
	# Direct way of doing calls
	JavaScriptBridge.eval("""alert("Hello from Godot!") """);

func _start_recognition() -> void:	
	print("[BridgeManager] Attempting to start recognition...")
	# Call the JavaScript `startRecognition` function defined in the custom HTML head
	window.startRecognition()
	
	print("[BridgeManager] On Speech Start callback!")
	speech_start.emit()

func _on_speech_result_callback(_args):
	print("[BridgeManager] On Speech Result callback!")
	var js_event = _args[0]
	var phrase = js_event.results[0][0].transcript;
	#var confidence = js_event.results[0][0].confidence;
	print("[BridgeManager]Phrase received: " + phrase)
	#print('[BridgeManager]Confidence: ' + confidence)
	speech_phrase.emit(phrase)

func _on_speech_end_callback(_args):
	print("[BridgeManager] On Speech End callback!")	
	speech_end.emit()

func _on_speech_nomatch_callback(_args):
	# Don't think we'll ever get this
	print("[BridgeManager] On Speech No Match callback!")	

func _on_speech_error_callback(_args):
	print("[BridgeManager] On Speech Error callback!")	
	speech_error.emit()
