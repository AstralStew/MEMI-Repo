class_name AudioPlayer
extends Node

@export var number_of_players := 3
@export var debugging = false

@export_category("Read Only")
@export var players : Array[AudioStreamPlayer] = []
@export var streams : Dictionary[String,AudioStreamPlayer] = {}

func _ready() -> void:
	if debugging: print("[AudioPlayer] Creating ",number_of_players," AudioStreamPlayers...")
	for count in number_of_players:
		var player = AudioStreamPlayer.new() 
		add_child(player)
		players.append(player)
		if debugging: print("[AudioPlayer] AudioStreamPlayer '",player,"' created.")

func play_stream(_stream:AudioStream,_volume:float=1.0) -> void:
	#stream = _stream
	#volume_linear = _volume
	#play()	
	if debugging: print("[AudioPlayer] Attempting to play '",_stream,"' at volume ",_volume,"...")
	for i in players.size():
		if players[i].playing:
			if debugging: print("[AudioPlayer] AudioStreamPlayer '",players[i],"' busy, skipping to next...")
			continue
		else:
			if debugging: print("[AudioPlayer] Playing audio from AudioStreamPlayer '",players[i],"'")
			players[i].stream = _stream
			players[i].volume_linear = _volume
			players[i].play()
			
			streams[_stream.resource_path] = players[i]
			players[i].finished.connect(_remove_stream_on_end)
			break
	push_error("[AudioPlayer] Could not find an unused AudioStreamPlayer! Cancelling. :( )")

func stop_stream(_stream:AudioStream) -> void:
	if debugging: print("[AudioPlayer] Attempting to stop '",_stream,"'")
	
	if streams.has(_stream.resource_path):
		if debugging: print("[AudioPlayer] Stopping AudioStreamPlayer '",streams[_stream.resource_path],"'.")
		streams[_stream.resource_path].stop()

func _remove_stream_on_end() -> void:
	if debugging: print("[AudioPlayer] Finished() signal recieved, removing streams that aren't playing...")
	var not_playing = []
	for key in streams:
		if !streams[key].playing:
			if debugging: print("[AudioPlayer] Noted stream '",key,"' as one to be removed...")
			not_playing.append(key)
	for key in not_playing:
		if debugging: print("[AudioPlayer] Removing stream '",key,"'")
		streams[key].finished.disconnect(_remove_stream_on_end)
		streams.erase(key)
	
