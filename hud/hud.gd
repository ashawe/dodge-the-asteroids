extends CanvasLayer

class_name HeadsUpDisplay

# Notifies `Main` node that the button has been pressed
signal start_game

const HEART_SCENE := preload("res://hud/heart.tscn")
const HIGH_SCORE_TEXT := "High Score: "
const NEW_HIGH_SCORE_TEXT := "New High Score: "
const DIFF_FONT := preload("res://fonts/Xolonium-Regular.ttf")
const MAX_DIFFICULTY_MESSAGES := 4
const MESSAGE_DISPLAY_TIME := 30
const MESSAGE_FADE_DURATION := 2.0
const MESSAGE_FONT_SIZE := 14

var message_label: Label
var score_label: Label
var high_score_label: Label
var difficulty_log: VBoxContainer
var _difficulty_entries: Array[Dictionary] = []
var message_timer: Timer
var start_button: Button
var heart_bar: CanvasGroup
var hearts: Array[Node] = []

func _ready() -> void:
	message_label = $MessageLabel
	message_timer = $MessageTimer
	score_label = $ScoreLabel
	difficulty_log = $DifficultyLog
	start_button = $StartNode2D/StartButton
	high_score_label = $HighScoreLabel
	heart_bar = $HeartBar


func show_message(text) -> void:
	message_label.text = text
	message_label.show()
	message_timer.start()

func show_high_score(score:int, is_new_high_score := false) -> void:
	if is_new_high_score:
		high_score_label.text = NEW_HIGH_SCORE_TEXT + str(score)
		score_label.visible = false
	else:
		high_score_label.text = HIGH_SCORE_TEXT + str(score)
	high_score_label.visible = true
	
func hide_high_score() -> void:
	score_label.visible = true
	high_score_label.visible = false

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
		var heart := HEART_SCENE.instantiate()
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


func add_difficulty_message(text: String) -> void:
	if _difficulty_entries.size() >= MAX_DIFFICULTY_MESSAGES:
		_remove_oldest_message()

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 0
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", style)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	panel.modulate = Color(1, 1, 1, 0)

	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.add_theme_font_override("font", DIFF_FONT)
	label.add_theme_font_size_override("font_size", MESSAGE_FONT_SIZE)
	panel.add_child(label)
	difficulty_log.add_child(panel)

	# Fade in
	var fade_in := create_tween()
	fade_in.tween_property(panel, "modulate:a", 0.7, 0.3)

	# Schedule auto-fade-out
	var auto_fade := create_tween()
	auto_fade.tween_interval(MESSAGE_DISPLAY_TIME)
	auto_fade.tween_property(panel, "modulate:a", 0.0, MESSAGE_FADE_DURATION)
	auto_fade.tween_callback(_on_difficulty_message_faded.bind(panel))

	_difficulty_entries.append({"panel": panel, "tween": auto_fade})


func _remove_oldest_message() -> void:
	if _difficulty_entries.is_empty():
		return
	var entry: Dictionary = _difficulty_entries.pop_front()
	var panel: PanelContainer = entry["panel"]
	var tween: Tween = entry["tween"]
	if tween and tween.is_valid():
		tween.kill()
	var fade := create_tween()
	fade.tween_property(panel, "modulate:a", 0.0, 0.3)
	fade.tween_callback(panel.queue_free)


func _on_difficulty_message_faded(panel: PanelContainer) -> void:
	if not is_instance_valid(panel):
		return
	for i in _difficulty_entries.size():
		if _difficulty_entries[i]["panel"] == panel:
			_difficulty_entries.remove_at(i)
			break
	panel.queue_free()


func clear_difficulty_messages() -> void:
	for entry in _difficulty_entries:
		var panel: PanelContainer = entry["panel"]
		var tween: Tween = entry["tween"]
		if tween and tween.is_valid():
			tween.kill()
		if is_instance_valid(panel):
			panel.queue_free()
	_difficulty_entries.clear()
