extends Node

const MAX_LIVES := 6
const INIT_LIVES := 3
const SAVE_FILE := "user://save.dat"
const FIRST_SPAWN_INTERVAL := 1.5

var asteroid_scene: PackedScene = preload("res://enemy/mob.tscn")
var pointer_scene: PackedScene = preload("res://hud/pointer.tscn")
@onready var bg_music: AudioStreamPlayer = $"/root/BgMusic"
@onready var game_over_music: AudioStreamPlayer = $GameOverMusic

@export var MIN_SPAWN_INTERVAL := 0.8
@export var MAX_SPAWN_INTERVAL := 1.0
@export var SPAWN_INTERVAL_STEP := 0.05
@export var SPAWN_INTERVAL_VARIANCE := 0.05

@export var MIN_MOB_SPEED := 80.0
@export var MAX_MOB_SPEED := 150.0
@export var MOB_SPEED_STEP := 7.5

@export var MIN_MOB_SCALE := 1.0
@export var MAX_MOB_SCALE := 2.0
@export var MOB_SCALE_STEP := 0.3

@export var MIN_DIRECTION_VARIENCE := 2
@export var MAX_DIRECTION_VARIENCE := 36
@export var DIRECTION_VARIENCE_STEP := 2


var score: int
var player: PlayerSpaceship
var hud: HeadsUpDisplay
var difficulty_timer: EnemyDifficultyTimer
var mob_timer: Timer
var mob_path: Path2D
var current_spawn_interval := FIRST_SPAWN_INTERVAL
var current_speed:= MIN_MOB_SPEED
var current_scale:= MIN_MOB_SCALE
var current_direction_varience := MIN_DIRECTION_VARIENCE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $Player
	difficulty_timer = $DifficultyTimer
	mob_timer = $MobTimer
	hud = $HUD
	mob_path = $HUD/MobPath
	hud.show_high_score(load_highscore())
	hud.setup_hearts(INIT_LIVES)


func game_over() -> void:
	hud.add_difficulty_message("Better luck next time...")
	game_over_music.play()
	bg_music.volume_db = -28
	hud.show_controls()
	clear_all_asteroids()
	if is_high_score(score):
		save_highscore(score)
		hud.show_high_score(score, true)
	else:
		hud.show_high_score(load_highscore())
	$ScoreTimer.stop()
	mob_timer.stop()
	difficulty_timer.stop()
	hud.show_game_over()


func new_game() -> void:
	difficulty_timer.resetTimer(true)
	difficulty_timer.start()
	score = 0
	player.start($StartPosition.position, INIT_LIVES)
	$StartTimer.start()
	hud.update_score(score)
	hud.hide_high_score()
	hud.hide_controls()
	hud.clear_difficulty_messages()
	hud.restore_all_hearts()
	hud.show_message("")
	hud.add_difficulty_message("Get Ready...")
	bg_music.volume_db = -18
	await hud.message_timer.timeout
	hud.add_difficulty_message("ASTEROIDS INCOMING!!!")
	current_spawn_interval = FIRST_SPAWN_INTERVAL
	current_speed = MIN_MOB_SPEED
	current_scale = MIN_MOB_SCALE
	current_direction_varience = MIN_DIRECTION_VARIENCE


func _on_mob_timer_timeout() -> void:
	mob_timer.wait_time = current_spawn_interval + randf_range(-SPAWN_INTERVAL_VARIANCE, SPAWN_INTERVAL_VARIANCE)
	# print("chosen spawn interval ", mob_timer.wait_time)
	
	# Create a new instance of the Mob scene.
	var mob: Asteroid = asteroid_scene.instantiate();
	
	# Choose a random location to spawn on Path2D.
	var mob_spawn_location: PathFollow2D = $HUD/MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	# Save position before the await — another timer callback could
	# change mob_spawn_location.progress_ratio during the wait.
	var spawn_pos := mob_spawn_location.position
	spawn_pointer(spawn_pos)
	# wait for spawn_pointer to flicker
	await get_tree().create_timer(1).timeout
	mob.player_ref = player
	# Convert screen-space position to world-space using the CURRENT canvas
	# transform so the mob appears at the screen edge after camera movement.
	mob.position = get_viewport().get_canvas_transform().affine_inverse() * spawn_pos
	mob.spawn_mob(current_speed, current_scale, current_direction_varience)
	add_child(mob)
	

func spawn_pointer(mob_spawn_position: Vector2):
	var pointer = pointer_scene.instantiate();
	hud.add_child(pointer)
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
	if not is_scale_capped():
		difficulty_options.append("scale")
	if not is_speed_capped():
		difficulty_options.append("speed")
		difficulty_options.append("speed")
	if not is_direction_capped():
		difficulty_options.append("aim")
		difficulty_options.append("aim")
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
			hud.add_difficulty_message("Asteroids are now spawning even faster!")
		"speed":
			current_speed += MOB_SPEED_STEP
			current_speed = clamp(current_speed, MIN_MOB_SPEED, MAX_MOB_SPEED)
			hud.add_difficulty_message("Asteroids are now even faster!")
		"scale":
			current_scale += MOB_SCALE_STEP
			current_scale = clamp(current_scale, MIN_MOB_SCALE, MAX_MOB_SCALE)
			hud.add_difficulty_message("Asteroids are now even bigger!")
		"aim":
			current_direction_varience += DIRECTION_VARIENCE_STEP
			current_direction_varience = clamp(current_direction_varience, MIN_DIRECTION_VARIENCE, MAX_DIRECTION_VARIENCE)
			hud.add_difficulty_message("Asteroids are now aiming even better!")
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


func is_direction_capped() -> bool:
	return current_direction_varience >= MAX_DIRECTION_VARIENCE


func clear_all_asteroids() -> void:
	var instances = get_tree().get_nodes_in_group("asteroids")
	for instance in instances:
		instance.queue_free()
