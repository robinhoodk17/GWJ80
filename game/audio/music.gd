extends AudioStreamPlayer

@export var next_player : AudioStreamPlayer

func _ready() -> void:
	finished.connect(play_next)
	Globals.restart.connect(on_restart)


func play_next() -> void:
	if next_player != null:
		next_player.play()


func transition(current_player : AudioStreamPlayer) -> void:
	var play_position : float = current_player.get_playback_position()
	current_player.stop()
	play(play_position)


func on_restart() -> void:
	play()
