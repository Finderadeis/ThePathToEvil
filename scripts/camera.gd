extends Camera2D

export var shake_falloff = 0.5
export var max_shake_offset = Vector2(100, 75)
export var max_shake_roll = 0.1

var shake_strength = 0.0

func _process(delta):
#    if target:
#        global_position = get_node(target).global_position
	if shake_strength > 0.0:
		shake_strength = max(shake_strength - shake_falloff * delta, 0)
		shake()


func start_shaking(amount):
	shake_strength = min(shake_strength + amount, 1.0)


func shake():
	var amount = pow(shake_strength, 2)
	rotation = max_shake_roll * amount * rand_range(-1, 1)
	offset.x = max_shake_offset.x * amount * rand_range(-1, 1)
	offset.y = max_shake_offset.y * amount * rand_range(-1, 1)
