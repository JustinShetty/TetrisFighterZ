extends Control

signal reset

onready var scene_tree: = get_tree()
onready var pause_overlay: ColorRect = $PauseOverlay

var paused: = false setget set_paused

func _unhandled_input(event) -> void:
	if event.is_action_pressed('pause'):
		self.paused = not paused
		scene_tree.set_input_as_handled()

func set_paused(value: bool) -> void:
	paused = value
	scene_tree.paused = value
	pause_overlay.visible = value
	if paused:
		$PauseOverlay/VBoxContainer/ResetButton.grab_focus()
	
func _process(_delta) -> void:
	$FpsLabel.text = str(Engine.get_frames_per_second())


func _on_QuitButton_button_up():
	get_tree().quit()


func _on_ResetButton_button_up():
	self.paused = not paused
	emit_signal('reset')
	
