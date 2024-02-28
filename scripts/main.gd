extends Node2D
# main script setting up level and keeping hud upt to date

enum MenuState {
	OFF,
	PAUSE,
	DEATH,
	OPTIONS,
	KEYBINDING,
	WIN,
}

# export variables, variable type and value are optional
export (Array, Material) var shader_mats

# public / private variables
var state

# onready variables

# Godot callback methods
func _ready():
	state = MenuState.OFF
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	give_player_to_hud()
	$BackgroundMusic.play()
	if Retry.music_on == false:
		$BackgroundMusic.set_volume_db(-100)
	for mat in shader_mats:
		mat.set_shader_param("level_size",$YSort/GameEndZone/WinTrigger.get_global_position().x)
	for mat in shader_mats:
		mat.set_shader_param("player_pos", $YSort/Player.get_global_position().x)


func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		match state:
			MenuState.OFF:
				$HUD/UI_Screens/SceneTransition.change_screen()
				$YSort/Player/Light2D.enabled = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				$HUD/UI_Screens/PauseScreen.show()
				get_tree().paused = true
				state = MenuState.PAUSE
			MenuState.PAUSE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				$HUD/UI_Screens/SceneTransition.change_screen()
				$HUD/UI_Screens/PauseScreen.hide()
				$YSort/Player/Light2D.enabled = true
				state = MenuState.OFF
				get_tree().paused = false
			MenuState.DEATH:
				pass
			MenuState.OPTIONS:
				$HUD/UI_Screens/SceneTransition.change_screen()
				$HUD/UI_Screens/OptionsScreen.hide()
				state = MenuState.PAUSE
			MenuState.KEYBINDING:
				$HUD/UI_Screens/SceneTransition.change_screen()
				$HUD/UI_Screens/KeybindingsScreen.hide()
				state = MenuState.OPTIONS
			MenuState.WIN:
				pass

	$HUD/FramerateLabel.text = str(Engine.get_frames_per_second())

# signal handling

func _on_Player_moved(pos):
	for mat in shader_mats:
		mat.set_shader_param("player_pos", pos.x)
	var border_offset = get_viewport().size.x
	$YSort/MovementConstraints/LevelTopBorder.position.x = pos.x - border_offset
	$YSort/MovementConstraints/LevelBottomBorder.position.x = pos.x - border_offset
	if !$YSort/EnemySpawner.pause_progress:
		$YSort/EnemySpawner/EnemyTypes.position.x = pos.x - 1000.0


func give_player_to_hud():
	$HUD.playernode = $YSort/Player
	$HUD/Tutorial.playernode = $YSort/Player


func _on_WinTrigger_body_entered(_body):
	yield(get_tree().create_timer(3.0), "timeout")
	$HUD/UI_Screens/SceneTransition.change_screen()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$YSort/Player/Light2D.enabled = false
	get_tree().paused = true
	$HUD/UI_Screens/WinScreen.show()


func _on_OptionsScreen_back_to_last():
	state = MenuState.PAUSE


func _on_KeybindingsScreen_back_to_last():
	state = MenuState.OPTIONS


func _on_OptionsScreen_to_keybind():
	state = MenuState.KEYBINDING
