extends Area2D


# export variables, variable type and value are optional
export (int) var main_attack_damage

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var mod = rng.randf_range(0.45,0.6)
	$Sprite.modulate = Color(mod,mod,mod)


# signal handling
func _on_damage_obj_area_entered(area):
	area.take_damage(main_attack_damage, get_global_position())
