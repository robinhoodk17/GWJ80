extends UiPage

var pausable : bool = false
@export var pause_action : GUIDEAction
@export var pause_music : AudioStreamPlayer
@export var timer_clock : HSlider
@export var timer_sprite : Sprite2D
var current_run : int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_connect_buttons")


func _connect_buttons() -> void:
	if ui:
		%Resume.pressed.connect(_resume)
		%Restart.pressed.connect(_restart)
		%Restart.pressed.connect(%TimeTravel.play)
		%Settings.pressed.connect(ui.go_to.bind("Settings"))
		%Settings.pressed.connect(%SettingsSFX.play)
		%Controls.pressed.connect(ui.go_to.bind("Controls"))
		%Controls.pressed.connect(%ControlsSFX.play)
		%MainMenu.pressed.connect(_main_menu)
		%Quit.pressed.connect(quit)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_back"):
		if visible:
			get_viewport().set_input_as_handled()
			_resume()
		else:
			set_timer_position()
			get_tree().paused = true
			ui.go_to("PauseMenu")
			%Restart.grab_focus()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$PauseSFX.play()
			#await get_tree().create_timer(.5).timeout
			pause_music.play()

func set_timer_position() -> void:
	timer_sprite.global_position.y = timer_clock.global_position.y
	var max_position = timer_clock.size.x
	var day_percentage = Globals.current_time/600
	timer_sprite.position.x = day_percentage * max_position

func _resume() -> void:
	pause_music.stop()
	$UnpauseSFX.play()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if ui:
		ui.go_to("Game")
	get_tree().paused = false


func _restart() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if ui:
		ui.go_to("Game")
	get_tree().paused = false
	Globals._restart()


func _main_menu() -> void:
	get_tree().set_deferred("paused", false)
	get_tree().change_scene_to_file("res://main.tscn")


func quit() -> void:
	#var quit_player : AudioStreamPlayer = $Buttons/Quit/QuitSFX
	#quit_player.play()
	get_tree().quit()


func show_ui() -> void:
	show()
	%Restart.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
