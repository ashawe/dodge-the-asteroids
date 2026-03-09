extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_changed.connect(_on_animation_changed)



func _on_animation_changed():
	# Make boost look big and good
	if self.animation == "power":
		self.scale = Vector2(1, 2) # Double the size
		self.position = Vector2(0.0, 3.0) # since size big, position need to change
	else:
		self.scale = Vector2(1, 1) # Normal size
		self.position = Vector2(0.0, 9.5) # Normal position
