extends Control

func _on_Menu_pressed():
	$"../SceneTransition".change_screen()
	get_tree().change_scene("res://scenes/ui/title_screen.tscn")


func _on_Quit_pressed():
	$"../SceneTransition".change_screen()
	get_tree().quit()
