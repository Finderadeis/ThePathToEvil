class_name State
extends Node
# Virtual base class for all states.


# public / private variables
var target
var state_machine = null
var movement_direction = Vector2(0,0)

# public / private functions
func enter():
	pass


func exit():
	state_machine.transition_to("Walk")


func update(_delta):
	pass


func get_user_input():
	if Input.is_action_pressed("main_attack"):
		state_machine.transition_to("StartAttack")
	elif Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")
	elif Input.is_action_pressed("ultimate"):
		if target.ult_charge >= target.ult_max_charge:
			state_machine.transition_to("Ultimate")
	elif Input.is_action_pressed("up") || Input.is_action_pressed("down") || Input.is_action_pressed("left") || Input.is_action_pressed("right"):
		state_machine.transition_to("Walk")

func get_movement_direction():
	var direction = Vector2(0,0)
	
	if Input.is_action_pressed("up"):
		direction.y = -1
	if Input.is_action_pressed("down"):
		direction.y = 1
	if Input.is_action_pressed("left"):
		direction.x = -1
		target.flip_sprite(true)
	if Input.is_action_pressed("right"):
		direction.x = 1
		target.flip_sprite(false)
		
	return direction.normalized()
