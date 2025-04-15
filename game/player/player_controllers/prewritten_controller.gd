extends Node
class_name prewritten

var frame_info : Array[Dictionary]
var player : CharacterBody3D
var physics_tick : int = 0
@onready var playermodel : Node3D = $"../playermodel"

func _ready() -> void:
	player = $".."
	$"../playermodel/Butterfly/AnimationPlayer".play("flap")
	Globals.restart.connect(restarted)


func _physics_process(delta: float) -> void:
	if physics_tick >= frame_info.size():
		return
	player.global_position = frame_info[physics_tick]["position"]
	playermodel.global_basis = frame_info[physics_tick]["rotation"]
	var current_talk : Dictionary = frame_info[physics_tick]["talk"]
	#print_debug(frame_info[physics_tick])
	if current_talk["talk_started"]:
		current_talk["npc"].current_gamestate = current_talk["talk_result"]
	physics_tick += 1


func restarted() -> void:
	physics_tick = 0
