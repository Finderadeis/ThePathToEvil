extends Control

# handles button functionality for credits screen

func _on_Back_pressed():
	$"../SceneTransition".change_screen()
	self.hide()
	$"..".state = $"..".MenuState.TITLE
