 extends Particles2D

var moving = false #the variable

func _ready():
	set_process_input(true)
	set_process(true)


func _input(_event):
	if Input.mouse_mode == 1:
		pass
	elif  InputEventMouseMotion:
		moving = true
		set_emitting(true)

func _process(_delta):
	var ms = get_global_mouse_position()
	set_global_position(Vector2(ms))
	set_emitting(moving)
	moving = false
