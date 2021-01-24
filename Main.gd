extends Node

export (PackedScene) var StartPauseMenu

var menu

func _ready():
	$Player.start($SpawnLoc.position)

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
