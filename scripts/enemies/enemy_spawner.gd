extends YSort
# Handles Spawning and Deleting enemies


# signals
signal enemy_destroyed(ult_perc, pos)

# export variables, variable type and value are optional

# enemy spawnrate per second
export (float) var start_spawnrate
export (float) var max_spawnrate = 2.0
export (float) var spawnrate_increase = 0.7

# max number of enemies to exist at the same time
export (int) var start_enemy_count = 6
export (int) var max_enemy_count

# public / private variables
var should_spawn = false
var pause_progress = false
var progress_distance = 0.0
var spawn_pause_timer = 0.0
var initial_player_position
var time_since_last_spawn = 0.0
var rng = RandomNumberGenerator.new()
var enemy_circle_direction = 1.0
var current_enemy_count = 0
var current_max_enemy_count
var current_spawnrate
var tutorial_enemies = Array()
var ult_enemy_dead = false

# Godot callback methods
func _ready():
	rng.randomize()
	current_max_enemy_count = start_enemy_count
	current_spawnrate = start_spawnrate
	initial_player_position = $"../Player".get_position()
	progress_distance = initial_player_position
	spawnrate_increase /= 10000.0
	set_enemy_starting_values()
	for enemy in $TutorialEnemies.get_children():
		tutorial_enemies.append(enemy)


func _physics_process(delta):
	if !should_spawn || pause_progress:
		return

	if spawn_pause_timer > 0:
		spawn_pause_timer -= delta
		return

	time_since_last_spawn += delta
	if time_since_last_spawn > 1.0/current_spawnrate:
		spawn_enemy()
		time_since_last_spawn = 0.0


# public / private functions

func set_enemy_starting_values():
	for enemy in $EnemyTypes.get_children():
		enemy.current_spawn_chance = enemy.start_spawn_chance
		enemy.spawn_chance_increase /= 10000.0
		enemy.current_max_count = enemy.start_count
		enemy.max_count_increase /= 10000.0
		enemy.current_count = 0
	calculate_spawn_ranges()


func set_enemy_values(enemy):
	enemy.connect("dying", self, "_on_Enemy_dying")
	enemy.connect("died", self, "_on_Enemy_died")
	enemy.position.y = rng.randf_range($TopConstraint.position.y, $BottomConstraint.position.y)
	enemy.position.x = $EnemyTypes.position.x
	enemy.last_player_position = $"../Player".get_global_position()
	enemy.target = $"../Player"
	enemy.circle_direction = enemy_circle_direction
	enemy_circle_direction *= -1.0
	enemy.is_template = false
	enemy.visible = true


func spawn_tutorial_enemy(id):
	if tutorial_enemies[id]:
		var enemy = tutorial_enemies[id].duplicate()
		set_enemy_values(enemy)
		$YSort.call_deferred("add_child", (enemy))

func spawn_enemy():
	if current_enemy_count >= current_max_enemy_count:
		return

	for enemy in $EnemyTypes.get_children():
		if current_spawnrate > enemy.start_spawnrate:
			enemy.can_spawn = true

	var enemy = get_random_enemy()
	current_enemy_count += 1
	set_enemy_values(enemy)
	$YSort.call_deferred("add_child", (enemy))


func get_random_enemy():
	var new_enemy
	var chance_sum = 0.0
	for enemy in $EnemyTypes.get_children():
		chance_sum += enemy.current_spawn_chance
	var rand = rng.randf_range(0.0,chance_sum)
	for enemy in $EnemyTypes.get_children():
		if rand >= enemy.spawn_range.x && rand < enemy.spawn_range.y && enemy.can_spawn && enemy.current_count < enemy.current_max_count:
			new_enemy = enemy.duplicate()
			new_enemy.type_id = enemy.type_id
			enemy.current_count += 1
			break
	if new_enemy == null:
		new_enemy = $EnemyTypes/Enemy.duplicate()
		new_enemy.type_id = 0
	return new_enemy


func calculate_spawn_ranges():
	var last = 0.0
	for enemy in $EnemyTypes.get_children():
		enemy.spawn_range = Vector2(last, last + enemy.current_spawn_chance)
		last += enemy.current_spawn_chance


func pause_spawning(duration):
	spawn_pause_timer = duration


func recalculate_spawnrate(distance_to_start):
	current_spawnrate = start_spawnrate + (distance_to_start.x * spawnrate_increase)
	if current_spawnrate > max_spawnrate:
		current_spawnrate = max_spawnrate


func recalculate_enemy_limits(distance_to_start):
	current_max_enemy_count = 0
	for enemy in $EnemyTypes.get_children():
		enemy.current_max_count = enemy.start_count + (distance_to_start.x * enemy.max_count_increase)
		current_max_enemy_count += enemy.current_max_count
	if current_max_enemy_count > max_enemy_count:
		current_max_enemy_count = max_enemy_count


func recalculate_enemy_chances(distance_to_start):
	for enemy in $EnemyTypes.get_children():
		if enemy.can_spawn:
			enemy.current_spawn_chance = enemy.start_spawn_chance + (distance_to_start.x * enemy.spawn_chance_increase)
	calculate_spawn_ranges()


# signal handling
func _on_Enemy_died(dead_enemy):
	for enemy in $EnemyTypes.get_children():
		if enemy.type_id == dead_enemy.type_id:
			enemy.current_count -= 1
	$YSort.remove_child(dead_enemy)
	dead_enemy.queue_free()


func _on_Enemy_dying(ult_perc, pos):
	emit_signal("enemy_destroyed", ult_perc, pos)
	current_enemy_count -= 1


func _on_Player_moved(pos):
	var distance_to_start = pos - initial_player_position
	if distance_to_start > progress_distance:
		pause_progress = false
		progress_distance = distance_to_start
		recalculate_spawnrate(progress_distance)
		recalculate_enemy_limits(progress_distance)
		recalculate_enemy_chances(progress_distance)
	else:
		pause_progress = true


func _on_TutorialTrigger_body_entered(_body):
	$"../TutorialTrigger".set_deferred("monitoring", false)
	spawn_tutorial_enemy(0)
	yield(get_tree().create_timer(1.5), "timeout")
	spawn_tutorial_enemy(0)

func _on_TutorialTrigger2_body_entered(_body):
	$"../TutorialTrigger2".set_deferred("monitoring", false)
	spawn_tutorial_enemy(0)
	yield(get_tree().create_timer(1.5), "timeout")
	spawn_tutorial_enemy(0)

func _on_TutorialTrigger3_body_entered(_body):
	$"../TutorialTrigger3".set_deferred("monitoring", false)
	spawn_tutorial_enemy(0)
	yield(get_tree().create_timer(1.5), "timeout")
	spawn_tutorial_enemy(0)
	yield(get_tree().create_timer(1.5), "timeout")
	spawn_tutorial_enemy(0)


func _on_EnemySpawnTrigger_body_entered(_body):
	should_spawn = true


func _on_UltEnemy_ult_enemy_died():
	ult_enemy_dead = true


func _on_StopSpawningTrigger_body_entered(body):
	should_spawn = false
