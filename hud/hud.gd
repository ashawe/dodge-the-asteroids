extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

const HeartScene := preload("res://hud/heart.tscn")

var message_label: Label
var score_label: Label
var message_timer: Timer
var start_button: Button
var heart_bar: CanvasGroup
var hearts: Array[Node] = []

func _ready() -> void:
	message_label = $MessageLabel
	message_timer = $MessageTimer
	start_button = $StartButton
	score_label = $ScoreLabel
	heart_bar = $HeartBar


func show_message(text) -> void:
	message_label.text = text
	message_label.show()
	message_timer.start()


func show_game_over() -> void:
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await message_timer.timeout

	message_label.text = "Dodge the Asteroids!"
	message_label.show()
	
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	start_button.show()


func update_score(score) -> void:
	score_label.text = str(score)


func setup_hearts(count: int, start_x := 448, spacing := -32) -> void:
	# Remove old hearts
	for heart in hearts:
		heart.queue_free()
	hearts.clear()
	# Create new hearts right-to-left
	for i in count:
		var heart := HeartScene.instantiate()
		heart.position = Vector2(start_x + i * spacing, 32)
		heart_bar.add_child(heart)
		hearts.append(heart)


func lose_heart(index: int) -> void:
	if index >= 0 and index < hearts.size():
		hearts[index].lose()


func restore_all_hearts() -> void:
	for heart in hearts:
		await get_tree().create_timer(0.33).timeout
		heart.restore()


func _on_start_button_pressed() -> void:
	start_button.hide()
	start_game.emit()


func _on_message_timer_timeout() -> void:
	message_label.hide()
