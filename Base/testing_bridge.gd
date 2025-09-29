extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BridgeManager._initialise()
	await get_tree().create_timer(1.0).timeout
	activate_speech()


func NewTest() -> void:
	# Example JavaScript function returning an array
	var js_code = """
	function getLastResult() {
		for (var i = event.resultIndex; i < lastResults.length; i++) {
			if (lastResults[i].isFinal) {
				var result = lastResults[i][0].transcript + ' (Confidence: ' + lastResults[i][0].confidence + ')';
				console.log("[HEADER] Result: ", result);
				return result;
			}
		}
	}
	getLastResult();
	"""
	var js_result = JavaScriptBridge.eval(js_code)
	print("Value from JavaScript: ", js_result)
	

func activate_speech() -> void:
	print("ACTIVATING SPEECH")
	BridgeManager._start_recognition()
	await get_tree().create_timer(8.0).timeout
	deactivate_speech()

func deactivate_speech() -> void:
	print("DEACTIVATING SPEECH")
	BridgeManager._stop_recognition()
	await get_tree().create_timer(4.0).timeout
	activate_speech()
