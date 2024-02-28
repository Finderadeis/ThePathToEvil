extends Node2D

var container_position = Vector2(0.0, 0.0)
var speed = 0.01
var rng = RandomNumberGenerator.new()
var direction = Vector2()
var flip = false
var game_end = false


func _ready():
	rng.randomize()


func _physics_process(delta):
	position = position.linear_interpolate(direction, speed)


func game_end_reached():
	game_end = true
	direction.x = rng.randf_range(container_position.x - 1000.0, container_position.x + 1000.0)
	direction.y = rng.randf_range(container_position.y + 500.0, container_position.y - 500.0)
	$SoulParticle/AnimationPlayer.play("game_end")


func _on_Timer_timeout():
	if game_end:
		return
	var x_offset = 0.0
	if flip:
		x_offset = -400.0
	else:
		x_offset = 400.0
	direction.x = rng.randf_range(container_position.x - x_offset, container_position.x)
	direction.y = rng.randf_range(container_position.y + 200.0, container_position.y)
	$SoulParticle.scale = Vector2(rng.randf_range(0.07, 0.16),rng.randf_range(0.07, 0.16))
