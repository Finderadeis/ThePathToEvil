class_name ExampleClass
extends Node
# Template Script for Guideline Reference
# Class description goes here


# signals
signal some_signal_happened(arguements_of_signal)


# enums
enum SomeEnumerator {
	STATE_1,
	STATE_2,
	STATE_3,
}


# constants
const SOME_CONSTANT_VARIABLE = 100


# export variables, variable type and value are optional
export (int) var variable_for_editor = "whatever"


# public / private variables
var some_bool = true


# onready variables
onready var _onready_var = "Some Value"


# Godot callback methods
func _init():
	pass


func _ready():
	pass


func _physics_process(delta):
	pass


# public / private functions
func do_something(some_value):
	# local variables only needed for this function go here
	var condition_a = true
	var condition_b = false
	
	if condition_a && condition_b:
		# do stuff
		pass
	else:
		if !condition_a || condition_b:
			# do some other stuff
			pass
			
	return


#func this_function_commented_out(for_whatever_reason):
#	# do stuff
#	pass


# signal handling
