extends Node

const MAX_LIVES := 6
const INIT_LIVES := 1
const SAVE_FILE := "user://save.dat"

@export var asteroid_scene: PackedScene
var score: int
var player: PlayerSpaceship
var hud: HeadsUpDisplay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $Player
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
	$MobTimer.stop()
	hud.show_game_over()


func new_game() -> void:
	score = 0
	player.start($StartPosition.position, INIT_LIVES)
	$StartTimer.start()
	hud.update_score(score)
	hud.hide_high_score()
	hud.show_message("Get Ready")
	hud.restore_all_hearts()


func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob: Asteroid = asteroid_scene.instantiate();
	
	# Choose a random location to spawn on Path2D.
	var mob_spawn_location: PathFollow2D = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	mob.spawn_mob(mob_spawn_location)
	
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_score_timer_timeout() -> void:
	score += 1
	hud.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

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
	
