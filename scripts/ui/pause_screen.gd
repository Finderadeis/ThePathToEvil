extends Control

# handles button functionality for pause screen

func _on_Continue_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$"../SceneTransition".change_screen()
	self.hide()
	$"../../../YSort/Player/Light2D".enabled = true
	get_tree().paused = false
	$"../../..".state = $"../../..".MenuState.OFF


func _on_Menu_pressed():
	$"../SceneTransition".change_screen()
	get_tree().change_scene("res://scenes/ui/title_screen.tscn")


func _on_Options_pressed():
	$"../SceneTransition".change_screen()
	$"../OptionsScreen".show()
	$"../../..".state = $"../../..".MenuState.OPTIONS


func _on_Quit_pressed():
	$"../SceneTransition".change_screen()
	get_tree().quit()


