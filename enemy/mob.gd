extends RigidBody2D

class_name Asteroid

@export var MOB_SCALE_VARIANCE := 0.25
@export var MOB_SPEED_VARIANCE := 3
@export var max_distance_from_player := 1000

var player_ref: PlayerSpaceship

@onready var destroy_music: AudioStreamPlayer2D = $DestroyStreamPlayer


func _physics_process(_delta: float) -> void:
	if player_ref and player_ref.is_inside_tree():
		if global_position.distance_to(player_ref.global_position) > max_distance_from_player:
			queue_free()


func spawn_mob(mob_speed: float, mob_scale: float, direction_varience: int):
	mob_speed += randf_range(-MOB_SPEED_VARIANCE, MOB_SPEED_VARIANCE)
	# Aim where the player will be when the asteroid arrives (intercept point).
	var target := _get_intercept_target(mob_speed)
	var direction := position.direction_to(target).angle()
	# giving players some leeway
	direction += randf_range(-PI / direction_varience, PI / direction_varience)
	rotation = direction
	
	var velocity := Vector2(mob_speed, 0.0)
	linear_velocity = velocity.rotated(direction)
	
	mob_scale += randf_range(-MOB_SCALE_VARIANCE, MOB_SCALE_VARIANCE)
	#print("chosen mob scale: ", mob_scale)
	#print("------------------------------")
	$Sprite2D.scale = Vector2(mob_scale, mob_scale)
	$CollisionShape2D.scale = Vector2(mob_scale, mob_scale)


func destroy() -> void:
	destroy_music.play()
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("Blast")
	await $AnimationPlayer.animation_finished
	queue_free()


## Solve for the point where the asteroid intercepts the moving player.
## Falls back to aiming directly at the player if no solution exists.
func _get_intercept_target(asteroid_speed: float) -> Vector2:
	var player_pos := player_ref.global_position
	var player_vel := player_ref.velocity
	var relative_pos := player_pos - position

	# Quadratic: (|V|² - s²)t² + 2(D·V)t + |D|² = 0
	var a := player_vel.length_squared() - asteroid_speed * asteroid_speed
	var b := 2.0 * relative_pos.dot(player_vel)
	var c := relative_pos.length_squared()
	var discriminant := b * b - 4.0 * a * c

	if discriminant >= 0:
		var sqrt_disc := sqrt(discriminant)
		var t1 := (-b - sqrt_disc) / (2.0 * a) if a != 0.0 else -c / b if b != 0.0 else -1.0
		var t2 := (-b + sqrt_disc) / (2.0 * a) if a != 0.0 else t1
		# Pick the smallest positive time
		var t := t1 if t1 > 0.0 else t2
		if t > 0.0:
			return player_pos + player_vel * t

	return player_pos
