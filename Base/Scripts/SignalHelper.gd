extends Control

func _cycle_language() -> void:
	LanguageManager._cycle_language()

func _set_language (lang: Constants.LanguageCode) -> void:
	LanguageManager._set_language(lang)

func _set_stretch_ratio (value:float):
	size_flags_stretch_ratio = value
