extends Node2D

export (PackedScene) var collectable_scene
export (float) var max_health
export (float) var collectable_spawn_chance
onready var animPlayer = $AniPlayer
onready var animTree = $AniTree
onready var animState = animTree.get("parameters/playback")



# public / private variables
var health


# Godot callback methods
func _ready():
	health = max_health


# public / private functions
func take_damage(_amount, _source_position, source_type):
		if source_type == "HeavyAttack":
			health = 0
		else:
			health -= 1
		if health >= 1:
			animState.travel("cut")
		else:
			animState.travel("vanish")
			var rng = rand_range(0,100)
			if rng <= collectable_spawn_chance:
				spawn_Collectable()


func spawn_Collectable():
	var new_collectable = collectable_scene.instance()
	new_collectable.position = position
	$"../..".add_child(new_collectable)


func _on_wobble_left_body_entered(body):
	if body.has_method("take_damage"):
		animState.travel("wobble_left")
#		$AniTree["parameters/conditions/is_wobbLeft"] = true

func _on_wobble_left_body_exited(body):
	if body.has_method("take_damage"):
		animState.travel("wobble_leftBack")
#		$AniTree["parameters/conditions/is_wLback"] = true

func _on_wobble_right_body_entered(body):
	if body.has_method("take_damage"):
		animState.travel("wobble_right")
#		$AniTree["parameters/conditions/is_wobbRight"] = true

func _on_wobble_right_body_exited(body):
	if body.has_method("take_damage"):
		animState.travel("wobble_rightBack")
#		$AniTree["parameters/conditions/is_wRback"] = true
