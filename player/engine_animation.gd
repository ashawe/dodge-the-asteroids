extends AnimatedSprite2D

func _ready() -> void:
	# Connect animation_changed signal programatically
	animation_changed.connect(_on_animation_changed)


# Make boost look big and good
func _on_animation_changed() -> void:
	if self.animation == "power":
		self.scale = Vector2(1, 2) # Double the size
		self.position = Vector2(0.0, 3.0) # since size big, position need to change
	else:
		self.scale = Vector2(1, 1) # Normal size
		self.position = Vector2(0.0, 9.5) # Normal position
