extends Node

signal player_died

@export var mob_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func reduce_life() -> void:
	$Player.lives -= 1
	hit_flash($Player)
	flicker($Player)
	match $Player.lives:
		2:
			hit_flash($HUD/HeartBar/Heart1, 0.5)
			flicker($HUD/HeartBar/Heart1, 0.5)
			await get_tree().create_timer(0.5).timeout
			$HUD/HeartBar/Heart1.frame = 4
		1: 
			hit_flash($HUD/HeartBar/Heart2, 0.5)
			flicker($HUD/HeartBar/Heart2, 0.5)
			await get_tree().create_timer(0.5).timeout
			$HUD/HeartBar/Heart2.frame = 4
		0:
			hit_flash($HUD/HeartBar/Heart3, 0.5)
			flicker($HUD/HeartBar/Heart3, 0.5)
			game_over()
			await get_tree().create_timer(0.5).timeout
			$HUD/HeartBar/Heart3.frame = 4
		_:
			pass
		

func game_over() -> void:
	player_died.emit()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()


func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	await get_tree().create_timer(0.33).timeout
	$HUD/HeartBar/Heart3.frame = 0
	await get_tree().create_timer(0.33).timeout
	$HUD/HeartBar/Heart2.frame = 0
	await get_tree().create_timer(0.33).timeout
	$HUD/HeartBar/Heart1.frame = 0


func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate();
	
	
	# Choose a random location to spawn on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position
	
	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2
	
	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(100.0, 150.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	# Choose random scale for the mob.
	var random_scale = randf_range(1.5, 2.5)
	mob.get_node("Sprite2D").scale = Vector2(random_scale, random_scale)
	mob.get_node("CollisionShape2D").scale = Vector2(random_scale, random_scale)
	
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func hit_flash(_target, duration = 1.0):
	_target.modulate = Color(2, 2, 2) # bright flash
	await get_tree().create_timer(duration).timeout
	_target.modulate = Color(1, 1, 1)


func flicker(_target, duration := 1.0, interval := 0.06):
	var t := 0.0
	while t < duration:
		_target.modulate.a = 0.3 if _target.modulate.a == 1.0 else 1.0
		await get_tree().create_timer(interval).timeout
		t += interval
	_target.modulate.a = 1.0


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
