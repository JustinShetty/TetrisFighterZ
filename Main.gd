extends Node

const PlayerScene = preload('res://player/Player.tscn')

var p1 = null
var p2 = null

func _ready():
	p1 = PlayerScene.instance()
	add_child(p1)
	p1.start(1, $SpawnLoc.position)
	p2 = PlayerScene.instance()
	add_child(p2)
	p2.start(2, $SpawnLoc2.position)


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
