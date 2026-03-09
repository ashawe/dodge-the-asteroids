extends Area2D

signal hit

const MAX_SPEED = 200
const CONSTANT_SPEED = 50
const ROTATION_SPEED = PI
const BOOST_SPEED = 75
const MAX_LIVES = 3

var lives = MAX_LIVES
var friction = 50
var velocity: Vector2 = Vector2.ZERO # The player's movement vector.
var screen_size # Size of the game windaaaow.

var is_first_press_done: bool = false
var is_invulnerable: bool = false
var is_dead: bool = false

var engine_animation: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	engine_animation = $EngineAnimation
	engine_animation.visible = false
	engine_animation.play()
	engine_animation.animation = "idle"
	#hide()


func start(pos):
	position = pos
	rotation = 0
	lives = MAX_LIVES
	is_dead = false
	$CollisionPolygon2D.disabled = false
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_dead:
		var acceleration = CONSTANT_SPEED
		if Input.is_action_pressed("ui_right"):
			rotation += ROTATION_SPEED * delta

		if Input.is_action_pressed("ui_left"):
			rotation -= ROTATION_SPEED * delta

		if Input.is_action_pressed("ui_up"):
			engine_animation.visible = true
			is_first_press_done = true
			acceleration += BOOST_SPEED
			velocity += Vector2.UP.rotated(rotation) * acceleration * delta
			velocity = velocity.limit_length(MAX_SPEED)
			engine_animation.animation = "power"
		else:
			if is_first_press_done:
				velocity += Vector2.UP.rotated(rotation) * acceleration * delta
				var speed := velocity.length()
				if speed > CONSTANT_SPEED:
					speed = move_toward(speed, CONSTANT_SPEED, friction * delta)
					velocity = velocity.normalized() * speed
			engine_animation.animation = "idle"
		if is_first_press_done:
			position += velocity * delta
			position = position.clamp(Vector2.ZERO, screen_size)
	#print(velocity)


func _on_body_entered(_body):
	if is_invulnerable:
		return
	is_invulnerable = true
	print("HIT")
	if _body.has_method("destroy"):
		_body.destroy()
	hit.emit()
	await get_tree().create_timer(1).timeout
	is_invulnerable = false


func die():
	hide() # Player disappears after being hit.
	is_first_press_done = false
	is_dead = true
	engine_animation.visible = false
	velocity = Vector2.ZERO
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionPolygon2D.set_deferred("disabled", true)
