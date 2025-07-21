extends Node


@export var currentLanguage : Constants.LanguageCode = Constants.LanguageCode.en

var debugging := true

var enNormalFont : FontVariation = null
var arNormalFont : FontVariation = null
var prsNormalFont : FontVariation = null
var zhNormalFont : FontVariation = null

const FONT_PATH := "res://AssetPacks/0_Shared/Fonts/"
const EN_PREFIX := "NotoSansEN"
const AR_PREFIX := "NotoSansArabic"
const PRS_PREFIX := "NotoSansArabic"
const ZH_PREFIX := "NotoSansSC"

# Called in ScreenController _ready()
func _initialise() -> void:
	
	_load_fonts()
	
	_set_language(currentLanguage)	
	#_get_language_text("SX_TEST")


func _load_fonts() -> void:
	if debugging: print("[LanguageManager] Loading fonts...")
	enNormalFont = load(FONT_PATH+EN_PREFIX+"-Normal.tres")
	arNormalFont = load(FONT_PATH+AR_PREFIX+"-Normal.tres")
	prsNormalFont = load(FONT_PATH+PRS_PREFIX+"-Normal.tres")
	zhNormalFont = load(FONT_PATH+ZH_PREFIX+"-Normal.tres")


func _get_language_text(key: String) -> String:
	if debugging: print("[LanguageManager] key = '",key,"', result: '",tr(key),"'")
	return tr(key)



func _set_language (lang: Constants.LanguageCode) -> void:
	var language = Constants.LanguageCode.keys()[lang]
	TranslationServer.set_locale(language)	
	currentLanguage = lang
	if debugging: print("[LanguageManager] Set language to: ",currentLanguage)

func _cycle_language() -> void:
	currentLanguage = (currentLanguage + 1) % Constants.LanguageCode.size()
	_set_language(currentLanguage)


func get_normal_font() -> FontVariation:
	match currentLanguage:
		Constants.LanguageCode.en:
			if debugging: print("[LanguageManager] NormalFont for English = '",enNormalFont,"'")
			return enNormalFont
		Constants.LanguageCode.ar:
			if debugging: print("[LanguageManager] NormalFont for Arabic = '",arNormalFont,"'")
			return arNormalFont
		Constants.LanguageCode.prs:
			if debugging: print("[LanguageManager] NormalFont for Dari = '",prsNormalFont,"'")
			return prsNormalFont
		Constants.LanguageCode.zh:
			if debugging: print("[LanguageManager] NormalFont for Chinese = '",zhNormalFont,"'")
			return zhNormalFont
		_:
			if debugging: print("[LanguageManager] ERROR -> Bad CurrentLanguage! Impossible?!? >:O")
			return null
