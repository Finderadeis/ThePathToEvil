class_name StateMachine
extends Node


# signals
signal transitioned_to(state_name)


# export variables, variable type and value are optional
export var initial_state := NodePath()


# public / private variables
var target


# onready variables
onready var state = get_node(initial_state)
onready var last_state = get_node(initial_state)


func _ready():
	target = $".."
	for child in get_children():
		child.state_machine = self
		child.target = target
	state.enter()


func _physics_process(delta):
	state.update(delta)


func transition_to(target_state):
	$"../Sounds/AttackChargeSound".stop()
	$"../ChargeParticles".emitting = false
	last_state = state
	state = get_node(target_state)
	state.enter()
	emit_signal("transitioned_to", state.name)


func transition_to_last(source_state):
	state = last_state
	last_state = source_state
	state.enter()
	emit_signal("transitioned_to", state.name)
