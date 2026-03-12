extends Node

const MAX_LIVES := 6
const INIT_LIVES := 3
const SAVE_FILE := "user://save.dat"
const FIRST_SPAWN_INTERVAL := 1.5

var asteroid_scene: PackedScene = preload("res://enemy/mob.tscn")
var pointer_scene: PackedScene = preload("res://hud/pointer.tscn")
@export var MIN_SPAWN_INTERVAL := 0.85
@export var MAX_SPAWN_INTERVAL := 1.0
@export var SPAWN_INTERVAL_STEP := 0.1
@export var SPAWN_INTERVAL_VARIANCE := 0.1

@export var MIN_MOB_SPEED := 100.0
@export var MAX_MOB_SPEED := 150.0
@export var MOB_SPEED_STEP := 7.5

@export var MIN_MOB_SCALE := 1.0
@export var MAX_MOB_SCALE := 2.0
@export var MOB_SCALE_STEP := 0.3

var score: int
var player: PlayerSpaceship
var hud: HeadsUpDisplay
var difficulty_timer: EnemyDifficultyTimer
var mob_timer: Timer
var current_spawn_interval := FIRST_SPAWN_INTERVAL
var current_speed:= MIN_MOB_SPEED
var current_scale:= MIN_MOB_SCALE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $Player
	difficulty_timer = $DifficultyTimer
	mob_timer = $MobTimer
	hud = $HUD
	hud.show_high_score(load_highscore())
	hud.setup_hearts(INIT_LIVES)


func game_over() -> void:
	if is_high_score(score):
		save_highscore(score)
		hud.show_high_score(score, true)
	else:
		hud.show_high_score(load_highscore())
	$ScoreTimer.stop()
	mob_timer.stop()
	hud.show_game_over()


func new_game() -> void:
	difficulty_timer.resetTimer(true)
	difficulty_timer.start()
	score = 0
	player.start($StartPosition.position, INIT_LIVES)
	$StartTimer.start()
	hud.update_score(score)
	hud.hide_high_score()
	hud.show_message("Get Ready")
	hud.restore_all_hearts()


func _on_mob_timer_timeout() -> void:
	mob_timer.wait_time = current_spawn_interval + randf_range(-SPAWN_INTERVAL_VARIANCE, SPAWN_INTERVAL_VARIANCE)
	# print("chosen spawn interval ", mob_timer.wait_time)
	
	# Create a new instance of the Mob scene.
	var mob: Asteroid = asteroid_scene.instantiate();
	
	# Choose a random location to spawn on Path2D.
	var mob_spawn_location: PathFollow2D = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	spawn_pointer(mob_spawn_location.position)
	# wait for spawn_pointer to flicker
	mob.spawn_mob(mob_spawn_location, current_speed, current_scale)
	await get_tree().create_timer(1).timeout
	add_child(mob)
	# Spawn the mob by adding it to the Main scene.
	

func spawn_pointer(mob_spawn_position: Vector2):
	var pointer = pointer_scene.instantiate();
	add_child(pointer)
	pointer.position = mob_spawn_position
	# left edge
	if floor(mob_spawn_position.x) == 0:
		pointer.left()
	elif floor(mob_spawn_position.y) == 0:
		pointer.top()
	elif ceil(mob_spawn_position.x) == 480:
		pointer.right()
	else:
		pointer.bottom()
	return


func _on_score_timer_timeout() -> void:
	score += 1
	hud.update_score(score)


func _on_start_timer_timeout() -> void:
	mob_timer.start()
	$ScoreTimer.start()


func _on_difficulty_timer_timeout() -> void:
	# print("CURRENT VALUES: ", current_speed, ", ", current_scale, ", ", current_spawn_interval)
	var difficulty_options:= []
	if not is_interval_capped():
		difficulty_options.append("interval")
		difficulty_options.append("interval")
		difficulty_options.append("interval")
	#else:
		# print("==============================")
		# print("INTERVAL CAPPED ")
		# print("==============================")
	if not is_scale_capped():
		difficulty_options.append("scale")
		difficulty_options.append("scale")
	#else:
		# print("==============================")
		# print("SCALE CAPPED ")
		# print("==============================")
	if not is_speed_capped():
		difficulty_options.append("speed")
		difficulty_options.append("speed")
		difficulty_options.append("speed")
	#else:
		# print("==============================")
		# print("SPEED CAPPED ")
		# print("==============================")
	
	# if everything is already capped,
	# we don't need to reset & start the timer and
	# we can directly return.
	if difficulty_options.is_empty():
		# print("ALL CAPPED ", current_speed, ", ", current_scale, ", ", current_spawn_interval)
		return

	var difficulty_parameter = difficulty_options.pick_random()
	match difficulty_parameter:
		"interval":
			current_spawn_interval -= SPAWN_INTERVAL_STEP
			current_spawn_interval = clamp(current_spawn_interval, MIN_SPAWN_INTERVAL, MAX_SPAWN_INTERVAL)
			# print("SPAWN INTERVAL DECREASED: ", current_spawn_interval)
			# print("==============================")
		"speed":
			current_speed += MOB_SPEED_STEP
			current_speed = clamp(current_speed, MIN_MOB_SPEED, MAX_MOB_SPEED)
			# print("MOB SPEED INCREASED. Now: ", current_speed)
			# print("==============================")
		"scale":
			current_scale += MOB_SCALE_STEP
			current_scale = clamp(current_scale, MIN_MOB_SCALE, MAX_MOB_SCALE)
			# print("MOB SCALE INCREASED. Now: ", current_scale)
			# print("==============================")
		"_":
			pass
	difficulty_timer.resetTimer()
	difficulty_timer.start()


func is_high_score(current_score: int) -> bool:
	return current_score > load_highscore()


func save_highscore(high_score: int) -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_16(high_score)
	file.close()


func load_highscore() -> int:
	if not FileAccess.file_exists(SAVE_FILE):
		return 0
	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	var highscore := file.get_16()
	file.close()
	return highscore
	

func is_speed_capped() -> bool:
	return current_speed >= MAX_MOB_SPEED


func is_scale_capped() -> bool:
	return current_scale >= MAX_MOB_SCALE


func is_interval_capped() -> bool:
	return current_spawn_interval <= MIN_SPAWN_INTERVAL
	
