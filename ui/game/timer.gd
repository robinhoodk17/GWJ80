extends Label

var current_run : int = 1
var start_counting : bool = false
var last_minute : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.restart.connect(on_restart)


func _process(delta: float) -> void:
	if !start_counting:
		return
	Globals.current_time += delta
	if Globals.current_time >= 540.0 and !last_minute:
		Globals.last_minute.emit()
		last_minute = true
	if Globals.current_time > 600.0:
		Globals._restart()
	update_ui(Globals.current_time)

func on_restart() -> void:
	last_minute = false
	Globals.current_time = 0.0
	current_run = Globals.run_number

func update_ui(total_time : float) -> void:
	var run_text : String
	match current_run:
		1: run_text = "first attempt"
		2: run_text = "second chance"
		3: run_text = "last chance"
	@warning_ignore("integer_division")
	var minutes : int = int(total_time)/60
	var seconds : float = 60 - (round_to_dec(total_time,3) - minutes*60)
	minutes = 9 - minutes
	var minutes_text : String = str(run_text, " 0", minutes, ":")
	if seconds > 10:
		text = str(minutes_text, "%05.3f" % seconds)
	else: 
		text = str(minutes_text, 0, "%05.3f" % seconds)
func round_to_dec(num : float, digit : int) -> float:
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
