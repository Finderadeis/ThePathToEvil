extends Node

export (bool) var random = true

onready var rock_variant = load("res://assets/environment/stone_2.png")
onready var rock_variant_NM = load("res://assets/environment/stone_2_NM.png")
onready var rock_variant_light = load("res://assets/environment/stone_2_lightFix.png")
onready var rock_variant_light_NM = load("res://assets/environment/stone_2_lightFix_NM.png")
onready var light = load("res://assets/environment/stone_1_lightFix.png")
onready var light_NM = load("res://assets/environment/stone_1_lightFix_NM.png")

var rng = RandomNumberGenerator.new()

func _ready():
	if random == true:
		rng.randomize()
		var mod = rng.randf_range(0.25,0.5)
		$Sprite.modulate = Color(mod,mod,mod)
#		if randi() % 10 <= 2:
#			$Sprite.flip_h = true
		if randi() % 100 <= 25:
			$Sprite.texture = rock_variant
			$Sprite.normal_map = rock_variant_NM
		elif randi() % 100 <= 50:
			$Sprite.texture = rock_variant_light
			$Sprite.normal_map = rock_variant_light_NM
		elif randi() % 100 <= 75:
			$Sprite.texture = light
			$Sprite.normal_map = light_NM
		elif randi() % 100 >= 75:
			pass
	else:
		pass
