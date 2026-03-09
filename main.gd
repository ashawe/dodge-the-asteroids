extends Node

const MAX_LIVES := 6
const INIT_LIVES := 1

@export var asteroid_scene: PackedScene
var score: int
var player: PlayerSpaceship

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $Player
	$HUD.setup_hearts(INIT_LIVES)


func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()


func new_game() -> void:
	score = 0
	player.start($StartPosition.position, INIT_LIVES)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$HUD.restore_all_hearts()


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
	$HUD.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
