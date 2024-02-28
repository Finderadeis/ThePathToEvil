extends State

func enter():
	$"../../Sprite".animation = "default"
	$"../../Sprite".playing = false


func update(_delta):
	get_user_input()
