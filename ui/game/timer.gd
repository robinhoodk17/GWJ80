extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.restart.connect(on_restart)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Globals.current_time += delta
	update_ui(Globals.current_time)

func on_restart() -> void:
	Globals.current_time = 0.0

func update_ui(total_time : float) -> void:
	@warning_ignore("integer_division")
	var minutes : int = int(total_time)/60
	var seconds : float = round_to_dec(total_time,3) - minutes*60
	var minutes_text : String = str(minutes, ":")
	if seconds > 10:
		text = str(minutes_text, "%05.3f" % seconds)
	else: 
		text = str(minutes_text, 0, "%05.3f" % seconds)
func round_to_dec(num : float, digit : int) -> float:
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
