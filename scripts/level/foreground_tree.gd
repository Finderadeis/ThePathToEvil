extends Node

export (bool) var random = true

var rng = RandomNumberGenerator.new()
func _ready():
	if random == true:
		rng.randomize()
		var mod = rng.randf_range(0.27,0.45)
		$Sprite.modulate = Color(mod,mod,mod)
		if randi() % 10 <= 2:
			$Sprite.flip_h = true
		else:
			pass
	else:
		pass
