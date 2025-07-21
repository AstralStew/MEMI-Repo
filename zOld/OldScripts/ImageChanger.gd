extends TextureRect

@export var runtimeImageArray: Array[Texture2D] = []


@export var index := 0

#func _ready() -> void:	
	#_set_texture(0)	

func _on_button_pressed() -> void:
	print_debug("Button pressed. Index = ", index, ", new Index = ",(index + 1 % runtimeImageArray.size()))
	index = (index + 1) %  runtimeImageArray.size()
	_set_texture(index)

func _on_button_pressed_set(new_index: int) -> void:
	print_debug("Button pressed. Index = ", index, ", new Index = ",clampi(new_index,0, runtimeImageArray.size()))
	index = clampi(new_index,0, runtimeImageArray.size())
	_set_texture(index)

func _set_texture(texture_index: int) -> void:	
	print_debug("setting texture")
	texture = runtimeImageArray[texture_index]
	#texture = load(runtimeImageArray[texture_index])
