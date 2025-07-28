class_name SentenceComparer extends Resource

#@export var active := false
#@export var phrases : Array[String] = []
#@export var targetPhrase := ""


@export var debug := false

@export var correctConditions : Array[PhraseCheck] = []
@export var wrongConditions : Array[String] = []

@export var correctAnim := ""
@export var wrongAnim := ""
@export var mumboAnim := ""
@export var dontKnowAnim := ""


func _init(_debug:=false, _correctConditions:Array[PhraseCheck] = [],_wrongConditions:Array[String] = [],_correctAnim := "",_wrongAnim := "",_mumboAnim := "",_dontKnowAnim := "") -> void:
	debug = _debug
	correctConditions = _correctConditions
	wrongConditions = _wrongConditions
	correctAnim = _correctAnim
	wrongAnim = _wrongAnim
	dontKnowAnim = _dontKnowAnim
	mumboAnim = _mumboAnim

func compare(sentence:String) -> String:	
	var correctCount = 0
	
	if debug: print("[SentenceComparer] Comparing the sentence '",sentence,"'")
	
	if sentence == "": return mumboAnim
	
	if correctConditions.size() > 0:
		for check in correctConditions:
			if check.resolve(sentence):
				correctCount += 1
		if correctCount == correctConditions.size():
			if debug: print("[SentenceComparer] Correct conditions found! Returning correctAnim ('",correctAnim,"')")
			return correctAnim
	else: if debug: print("[SentenceComparer] WARNING -> Missing correct conditions on compare. Bit weird, but skipping...")
	
	if wrongConditions.size() > 0:
		for phrase in wrongConditions:
			if sentence.containsn(phrase):
				if debug: print("[SentenceComparer] Wrong conditions found! Returning wrongAnim ('",wrongAnim,"')")
				return wrongAnim
	else: if debug: print("[SentenceComparer] No wrong conditions on compare. Skipping...")
	
	if sentence.containsn("don't know") || sentence.containsn("do not know") || sentence.containsn("unsure") || sentence.containsn("not sure"):
		if debug: print("[SentenceComparer] User said 'I don't know'! Returning dontKnowAnim ('",dontKnowAnim,"')")
		return dontKnowAnim
	
	if debug: print("[SentenceComparer] No matches found! Returning mumboAnim ('",mumboAnim,"')")
	return mumboAnim



#
#var recentResult := false
#
#signal correct_match
#signal incorrect_match
#signal no_match
#
#signal correct_match_with(phrase)
#signal incorrect_match_with(phrase)
#signal no_match_with(phrase)
#
#func _ready() -> void:
	#BridgeManager.speech_start.connect(_on_start)
	#BridgeManager.speech_phrase.connect(_compare)
	#BridgeManager.speech_error.connect(_on_error)
	#BridgeManager.speech_end.connect(_on_end)
#
#func _on_start():
	#recentResult = false
#
#func _on_error():
	#if (active):
		#no_match.emit()
#
#func _on_end():
	#if (active):
		#if recentResult:
			#if debug: print("[",name,"/PhraseComparer] On End; Recent result found. Not emitting.")
			#return
		#
		#if debug: print("[",name,"/PhraseComparer] On End; Waiting for 1 second.")
		#await get_tree().create_timer(1).timeout 
		#if debug: print("[",name,"/PhraseComparer] Finished waiting.")
		#
		#if !recentResult:
			#if debug: print("[",name,"/PhraseComparer] No recent result. Emitting No Match.")
			#no_match.emit()
		#elif debug: print("[",name,"/PhraseComparer] Recent result found. Not emitting.")
#
##func _on_end():
	##if (active):
		##if (!recentResult):
			##no_match.emit()
		##recentResult = false


#
#
#func _compare(newPhrase:String) -> void:
	#if !active:
		#if debug: print("[",name,"/PhraseComparer] Not active, cancelling.")
		#return		
	#if debug: print("[",name,"/PhraseComparer] Compare; new phrase = " + newPhrase)
	#
	#recentResult = true
	#
	#if newPhrase.containsn(targetPhrase):
		#if debug:
			#print("[",name,"/PhraseComparer] Correct matching phrase! ('",newPhrase,"')")
		#correct_match.emit()
		#correct_match_with.emit(targetPhrase)
		#return
	#
	#for phrase in phrases:
		#if newPhrase.containsn(phrase):
			#if debug:
				#print("[",name,"/PhraseComparer] Incorrect matching phrase. ('",newPhrase,"')")
			#incorrect_match.emit()
			#incorrect_match_with.emit(phrase)
			#return
	#
	#if debug:
		#print("[",name,"/PhraseComparer] No matching phrase... ('",newPhrase,"')")
	#no_match.emit()
	#no_match_with.emit(newPhrase)
