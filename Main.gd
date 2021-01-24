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

func _process(_delta):
	pass

func new_game():
	get_tree().reload_current_scene()

func reset_signal_handler():
	new_game()

func player_lives_updated():
	$UserInterface/UserInterface/LivesLabel.text = str($Player.lives)
	if $Player.lives == 0:
		new_game()

func _on_Player_updated_move_state():
	var state_str = ''
	if $Player.move_state == $Player.ms.IDLE:
		state_str = 'IDLE'
	elif $Player.move_state == $Player.ms.WALK:
		state_str = 'WALK'
	elif $Player.move_state == $Player.ms.DASH:
		state_str = 'DASH'
	$UserInterface/UserInterface/MoveStateLabel.text = state_str
