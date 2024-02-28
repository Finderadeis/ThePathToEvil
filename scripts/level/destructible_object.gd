extends KinematicBody2D


# export variables, variable type and value are optional
export (PackedScene) var collectable_scene
export (float) var max_health
export (float) var collectable_spawn_chance


# public / private variables
var health
var invuln = false
var rng = RandomNumberGenerator.new()


# Godot callback methods
func _ready():
	rng.randomize()
#	var mod = rng.randf_range(0.32,0.45)
#	$Sprite.modulate = Color(mod,mod,mod)
	health = max_health
	if randi() % 100 <= 20:
		$Sprite.flip_h = true
	scale = Vector2(1,1) * (1 + (position.y - 750) / 1400)


# public / private functions
func take_damage(_amount, _source_position, source_type):
	if invuln:
		return
	else:
		invuln = true
		$Particles2D.emitting = true
		yield(get_tree().create_timer(0.2), "timeout")
		invuln = false
		$Particles2D.emitting = false
		
		if source_type == "HeavyAttack":
			health = 0
		else:
			health -= 1
		if health >= 1:
			$AnimationPlayer.play("damaged_object")
			if Retry.sfx_on:
				$HurtSound.play()
		else:
			$AnimationPlayer.play("Die")
			if Retry.sfx_on:
				$DeathSound.play()
			rng = rand_range(0,100)
			if rng <= collectable_spawn_chance:
				spawn_Collectable()


func get_vuln_status():
	return invuln

func spawn_Collectable():
	var new_collectable = collectable_scene.instance()
	new_collectable.position = position
	new_collectable.scale = scale
	$"../..".call_deferred("add_child", (new_collectable))
