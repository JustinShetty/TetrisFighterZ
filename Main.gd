extends Node

export (PackedScene) var StartPauseMenu

onready var iface = $UserInterface.get_node('UserInterface')

var menu

func _ready():
	$Player.start($SpawnLoc.position)

func _process(_delta):
	pass

func new_game():
	get_tree().reload_current_scene()

func _input(event):
	if event.is_action_pressed('reset'):
		new_game()

func player_lives_updated():
	iface.get_node('LivesLabel').text = str($Player.lives)
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
	iface.get_node('MoveStateLabel').text = state_str
