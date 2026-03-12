extends Node2D

class_name Pointer

@onready var exclamation: Sprite2D = $Exclamation
@onready var arrow: Sprite2D = $Arrow
@onready var exclamation_effects: EffectsComponent = $Exclamation/HitFlashAndFlickerComponent
@onready var arrow_effects: EffectsComponent = $Arrow/HitFlashAndFlickerComponent

func left():
	arrow.rotation_degrees = 180
	arrow.position.x += 4
	exclamation.position.x += 10
	do_effects()


func right():
	arrow.position.x -= 4
	exclamation.position.x -= 10
	do_effects()


func top():
	arrow.rotation_degrees = 270
	arrow.position.y += 4
	exclamation.position.y += 14
	do_effects()


func bottom():
	arrow.rotation_degrees = 90
	arrow.position.y -= 4
	exclamation.position.y -= 14
	do_effects()


func do_effects():
	exclamation_effects.flicker(exclamation, 1, 0.05)
	arrow_effects.flicker(arrow, 1, 0.06)
	await get_tree().create_timer(1.1).timeout
	queue_free()
