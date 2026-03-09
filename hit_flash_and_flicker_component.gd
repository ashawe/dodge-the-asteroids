extends Node

class_name EffectsComponent

@export var target: CanvasItem

func _ready() -> void:
	if target == null and get_parent() is CanvasItem:
		target = get_parent()

func hit_flash(_target: CanvasItem = null, duration := 1.0) -> void:
	if _target == null:
		_target = target
	_target.modulate.r = 2
	_target.modulate.g = 2
	_target.modulate.b = 2
	await get_tree().create_timer(duration).timeout
	_target.modulate.r = 1
	_target.modulate.g = 1
	_target.modulate.b = 1


func flicker(_target: CanvasItem = null, duration := 1.0, interval := 0.06) -> void:
	if _target == null:
		_target = target
	var t := 0.0
	while t < duration:
		_target.modulate.a = 0.3 if _target.modulate.a == 1.0 else 1.0
		await get_tree().create_timer(interval).timeout
		t += interval
	_target.modulate.a = 1.0
