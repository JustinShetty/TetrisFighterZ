extends Node

const PlayerScene = preload('res://player/Player.tscn')

var p0 = null
var p1 = null

func _ready():
	p0 = PlayerScene.instance()
	add_child(p0)
	p0.start(0, $SpawnLoc0.position)
	# p1 = PlayerScene.instance()
	# add_child(p1)
	# p1.start(1, $SpawnLoc1.position)
	
	# for id in Input.get_connected_joypads():
	#	print(Input.get_joy_name(id))

func reset_signal_handler():
	get_tree().reload_current_scene()
