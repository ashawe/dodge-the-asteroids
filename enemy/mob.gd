extends RigidBody2D

class_name Asteroid

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()


func spawn_mob(mob_spawn_path: PathFollow2D):
	position = mob_spawn_path.position
	
	# Set the mob's direction perpendicular to the path direction.
	var direction := mob_spawn_path.rotation + PI / 2
	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	rotation = direction
	
	# Choose the velocity for the mob.
	var velocity := Vector2(randf_range(100.0, 150.0), 0.0)
	linear_velocity = velocity.rotated(direction)
	
	# Choose random scale for the mob.
	var random_scale := randf_range(1.5, 2.5)
	$Sprite2D.scale = Vector2(random_scale, random_scale)
	$CollisionShape2D.scale = Vector2(random_scale, random_scale)

func destroy() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("Blast")
	await $AnimationPlayer.animation_finished
	queue_free()
