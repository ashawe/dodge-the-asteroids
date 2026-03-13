extends RigidBody2D

class_name Asteroid

@export var MOB_SCALE_VARIANCE := 0.5
@export var MOB_SPEED_VARIANCE := 5

@onready var destroy_music: AudioStreamPlayer2D = $DestroyStreamPlayer

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()


func spawn_mob(mob_spawn_path: PathFollow2D, mob_speed: float, mob_scale: float):
	position = mob_spawn_path.position
	
	# Set the mob's direction perpendicular to the path direction.
	var direction := mob_spawn_path.rotation + PI / 2
	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	rotation = direction
	
	mob_speed += randf_range(-MOB_SPEED_VARIANCE, MOB_SPEED_VARIANCE)
	#print("chosen mob speed: ", mob_speed)
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
