extends Control

## handles button functionality for options screen

export (bool) var ingame = false

signal back_to_last
signal to_keybind

func _ready():
	if Retry.sfx_on:
		$Buttons/Sound/Label.text = "turn off sfx"
		$Buttons/Sound.modulate = Color(1,1,1)
	else:
		$Buttons/Sound/Label.text = "turn on sfx"
		$Buttons/Sound.modulate = Color(0.74,0.60,0.79)
		
	if Retry.music_on:
		$Buttons/Music/Label.text = "turn off music"
		$Buttons/Music.modulate = Color(1,1,1)
	else:
		$Buttons/Music/Label.text = "turn on music"
		$Buttons/Music.modulate = Color(0.74,0.60,0.79)


func _on_Back_pressed():
	$"../SceneTransition".change_screen()
	self.hide()
	emit_signal("back_to_last")

func _on_Keybindings_pressed():
	emit_signal("to_keybind")
	$"../SceneTransition".change_screen()
	$"../KeybindingsScreen".show()


func _on_Sound_pressed():
	if Retry.sfx_on:
		Retry.sfx_on = false
		$Buttons/Sound/Label.text = "turn on sfx"
		$Buttons/Sound.modulate = Color(0.74,0.60,0.79)
	else:
		Retry.sfx_on = true
		$Buttons/Sound/Label.text = "turn off sfx"
		$Buttons/Sound.modulate = Color(1,1,1)

func _on_Music_pressed():
	if Retry.music_on:
		if ingame:
			$"../../../BackgroundMusic".set_volume_db(-80)
		if ingame == false:
			$"../MenuMusic".set_volume_db(-80)
		Retry.music_on = false
		$Buttons/Music/Label.text = "turn on music"
		$Buttons/Music.modulate = Color(0.74,0.60,0.79)
	else:
		if ingame:
			$"../../../BackgroundMusic".set_volume_db(-25)
		if ingame == false:
			$"../MenuMusic".set_volume_db(-20)
		Retry.music_on = true
		$Buttons/Music/Label.text = "turn off music"
		$Buttons/Music.modulate = Color(1,1,1)
