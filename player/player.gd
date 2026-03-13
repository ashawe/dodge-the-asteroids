extends Area2D

class_name PlayerSpaceship

signal player_got_hit(int)
signal player_died

const MAX_SPEED := 200
const CONSTANT_SPEED := 50
const ROTATION_SPEED := PI
const BOOST_SPEED := 75

var effects: EffectsComponent
var lives := 3
var friction := 50
var velocity: Vector2 = Vector2.ZERO # The player's movement vector.
var screen_size # Size of the game window.

@onready var ship_base: Sprite2D = $ShipBase

var is_first_press_done: bool = false
var is_invulnerable: bool = false
var is_dead: bool = false

var engine_animation: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	effects = $HitFlashAndFlickerComponent
	screen_size = get_viewport_rect().size
	engine_animation = $EngineAnimation
	engine_animation.visible = false
	engine_animation.play()
	engine_animation.animation = "idle"
	#hide()


func start(start_position: Vector2, _lives: int) -> void:
	ship_base.texture = load("res://art/PlayerShip/Main Ship - Base - Full health.png")
	position = start_position
	self.lives = _lives
	rotation = 0
	is_dead = false
	is_invulnerable = false
	is_first_press_done = false
	$CollisionPolygon2D.disabled = false
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	if not is_dead:
		var acceleration := CONSTANT_SPEED
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


func _on_body_entered(body) -> void:
	# giving player a breathing room
	if is_invulnerable:
		return
	is_invulnerable = true
	
	if body.has_method("destroy"):
		body.destroy()
	
	# reduce player's lives
	lives -= 1
	
	# flicker and reduce heart
	player_got_hit.emit(lives)
	
	# if player_died, handle death
	if (lives <= 0):
		player_died.emit()
		die()
	else:
		update_ship_damage_texture()
		# show and wait for hit effect and then continue the game
		effects.hit_flash(self, 1.0)
		effects.flicker(self, 1.0)
		await get_tree().create_timer(1).timeout
		is_invulnerable = false

func update_ship_damage_texture():
	match lives:
		3:
			ship_base.texture = load("res://art/PlayerShip/Main Ship - Base - Slight damage.png")
		2:
			ship_base.texture = load("res://art/PlayerShip/Main Ship - Base - Damaged.png")
		1:
			ship_base.texture = load("res://art/PlayerShip/Main Ship - Base - Very damaged.png")
		_:
			ship_base.texture = load("res://art/PlayerShip/Main Ship - Base - Full health.png")

func die() -> void:
	hide() # Player disappears after being hit.
	is_dead = true
	engine_animation.visible = false
	velocity = Vector2.ZERO
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionPolygon2D.set_deferred("disabled", true)
