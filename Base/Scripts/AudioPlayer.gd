extends AudioStreamPlayer


func play_stream(_stream:AudioStream,_volume:float=1.0) -> void:
	stream = _stream
	volume_linear = _volume
	play()
