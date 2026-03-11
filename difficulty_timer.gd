extends Timer

class_name EnemyDifficultyTimer

@export_range(10, 30, 1) var FIRST_DIFF_INCREASE_TIME := 10.0
@export var MIN_INCREASE_TIME := 20
@export var MAX_INCREASE_TIME := 30

func resetTimer(is_new_game:bool = false) -> void:
	if is_new_game:
		wait_time = FIRST_DIFF_INCREASE_TIME
		return
	wait_time = randf_range(MIN_INCREASE_TIME, MAX_INCREASE_TIME)
