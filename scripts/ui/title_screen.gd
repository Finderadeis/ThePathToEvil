extends Control

# handles button functionality for title screen

enum MenuState {
	TITLE,
	OPTIONS,
	CREDITS,
	KEYBINDINGS,
	STARTING,
}

var state

func _ready():
	state = MenuState.TITLE
	$MenuMusic.play()
	if Retry.music_on:
		$MenuMusic.set_volume_db(-10)
	if Retry.music_on == false:
		$MenuMusic.set_volume_db(-80)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		$SceneTransition.change_screen()
		match state:
			MenuState.TITLE:
				get_tree().quit()
			MenuState.OPTIONS:
				$OptionsScreen.hide()
				state = MenuState.TITLE
			MenuState.CREDITS:
				$CreditsScreen.hide()
				state = MenuState.TITLE
			MenuState.KEYBINDINGS:
				$KeybindingsScreen.hide()
				state = MenuState.OPTIONS
			MenuState.STARTING:
				get_tree().reload_current_scene()


func _on_Start_pressed():
	state = MenuState.STARTING
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Retry.active = false
	$StartPlayer.play("Start")


func _on_Retry_pressed():
	state = MenuState.STARTING
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Retry.active = true
	$StartPlayer.play("Start")


func _on_Options_pressed():
	state = MenuState.OPTIONS
	$SceneTransition.change_screen()
	$OptionsScreen.show()


func _on_About_pressed():
	state = MenuState.CREDITS
	$SceneTransition.change_screen()
	$CreditsScreen.show()


func _on_Quit_pressed():
	$SceneTransition.change_screen()
	get_tree().quit()


func _on_StartPlayer_animation_finished(_Start):
	get_tree().change_scene("res://scenes/main.tscn")


func _on_OptionsScreen_back_to_last():
	state = MenuState.TITLE


func _on_KeybindingsScreen_back_to_last():
	state = MenuState.OPTIONS


func _on_OptionsScreen_to_keybind():
	state = MenuState.KEYBINDINGS
