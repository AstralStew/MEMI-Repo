class_name PhraseCheck extends Resource

@export var checkType : Constants.CheckType = Constants.CheckType.AND
@export var phrases : Array[String] = []

func _init(_checkType:Constants.CheckType=Constants.CheckType.AND,_phrases:Array[String]=[]):
	checkType = _checkType
	phrases = _phrases

func resolve (sentence:String):
	if phrases.is_empty():
		print ("[PhraseCheck]ERROR-> No check phrases defined! Skipping...")
		return true

	if checkType == Constants.CheckType.AND:
		for phrase in phrases:
			if !sentence.containsn(phrase):
				return false
		return true
	else:
		for phrase in phrases:
			if sentence.containsn(phrase):
				return true
		return false
