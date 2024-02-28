extends KinematicBody2D


# export variables, variable type and value are optional
export (PackedScene) var collectable_scene
export (float) var max_health
export (float) var collectable_spawn_chance


# public / private variables
var health

# Godot callback methods
func _ready():
	health = max_health
	if randi() % 100 <= 20:
		$Sprite.flip_h = true

# public / private functions
func take_damage(_amount, _source_position, source_type):
		if source_type == "HeavyAttack":
			health = 0
		else:
			health -= 1
		if health >= 1:
			$AnimationPlayer.play("damaged_object")
		else:
			$AnimationPlayer.play("Die")
			var rng = rand_range(0,100)
			if rng <= collectable_spawn_chance:
				spawn_Collectable()


func spawn_Collectable():
	var new_collectable = collectable_scene.instance()
	new_collectable.position = position
	$"../..".call_deferred("add_child", (new_collectable))
