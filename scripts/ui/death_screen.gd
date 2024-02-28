extends Control

# handles button functionality for death screen

func _on_Player_died():
	$"../SceneTransition".change_screen()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	self.show()
	$"../../..".state = $"../../..".MenuState.DEATH


func _on_Retry_pressed():
	Retry.active = true
	get_tree().paused = false
	get_tree().change_scene("res://scenes/main.tscn")


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
