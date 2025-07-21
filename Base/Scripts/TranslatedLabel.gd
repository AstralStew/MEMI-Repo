extends Label

@export var translationKey := ""

func _ready() -> void:
	_populate()

func _populate() -> void:
	print("[TranslatedLabel] key = '",translationKey,"', result: '",tr(translationKey))
	await get_tree().create_timer(0.1).timeout
	text = tr(translationKey)

func _populateWith(_newKey : String) -> void:
	print("[TranslatedLabel] key = '",translationKey,"', result: '",tr(translationKey))
	await get_tree().create_timer(0.1).timeout
	text = tr(translationKey)
