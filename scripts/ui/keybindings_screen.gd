extends Control

# handles button functionality for keybindings screen

signal back_to_last

func _on_Back_pressed():
	$"../SceneTransition".change_screen()
	self.hide()
	$"../OptionsScreen".show()
	emit_signal("back_to_last")
