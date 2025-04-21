extends AudioStreamPlayer

func _ready() -> void:
	Global.playing = true

func _process(delta: float) -> void:
	if Global.playing == false and self.playing:
		self.stream_paused = true
	elif Global.playing == true and ! self.playing:
		self.stream_paused = false
