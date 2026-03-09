extends Sprite2D

const FRAME_FULL := 0
const FRAME_EMPTY := 4

@onready var effects: EffectsComponent = $HitFlashAndFlickerComponent

func lose(duration := 0.5) -> void:
	effects.hit_flash(self, duration)
	effects.flicker(self, duration)
	await get_tree().create_timer(duration).timeout
	frame = FRAME_EMPTY

func restore() -> void:
	frame = FRAME_FULL
