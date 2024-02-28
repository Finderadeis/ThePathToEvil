extends Area2D
# delegates body damage and heal signal to player script

onready var player = get_parent()

# signals
signal got_hit(damage, source_position)
signal gained_health(amount)

signal mask_collected()


# public / private functions
func take_damage(dmg, source):
	emit_signal("got_hit", dmg, source)


func refill_health(amount):
	emit_signal("gained_health", amount)
	
func health_full():
	if player.health >= player.max_health:
		return true
	else:
		return false


#mask hud
func mask_counter():
	emit_signal("mask_collected")
