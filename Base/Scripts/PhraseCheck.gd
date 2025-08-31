class_name PhraseCheck extends Resource

@export var checkType : Constants.CheckType = Constants.CheckType.AND
@export var phrases : Array[String] = []

func _init(_checkType:Constants.CheckType=Constants.CheckType.AND,_phrases:Array[String]=[]):
	checkType = _checkType
	phrases = _phrases

func resolve (sentence:String, _debug:bool=false):
	if phrases.is_empty():
		print ("[PhraseCheck] ERROR-> No check phrases defined! Skipping...")
		return true

	if checkType == Constants.CheckType.AND:
		for phrase in phrases:
			if !sentence.containsn(phrase):
				if _debug: push_warning("[PhraseCheck] AND Sentence did NOT contain '",phrase,"', returning false!")
				return false
			elif _debug: print("[PhraseCheck] AND Sentence contained '",phrase,"', continuing...")
		if _debug: print("[PhraseCheck] AND Phrase check finished! Returning true...")
		return true
	else:
		for phrase in phrases:
			if sentence.containsn(phrase):
				if _debug: print("[PhraseCheck] OR NOTE -> Sentence contained '",phrase,"', returning true!")
				return true
			elif _debug: print("[PhraseCheck] OR Sentence did NOT contain '",phrase,"', continuing...")
		if _debug: push_warning("[PhraseCheck] OR Sentence did NOT contain any of the phrases, returning false!")
		return false
