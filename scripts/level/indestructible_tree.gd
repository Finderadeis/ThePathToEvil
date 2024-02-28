extends Node

export (bool) var random = true
onready var light = load("res://assets/environment/treeStump_1_lightFix.png")

var rng = RandomNumberGenerator.new()

func _ready():
	if random == true:
		rng.randomize()
		var mod = rng.randf_range(0.35,0.5)
		$Sprite.modulate = Color(mod,mod,mod)
		if randi() % 10 <= 2:
			$Sprite.flip_h = true
		if randi() % 100 <= 50:
			$Sprite.texture = light
		else:
			pass
	else:
		pass
