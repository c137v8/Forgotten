extends CanvasLayer

onready var target = $ColorRect2
onready var tween = Tween.new()
onready var sound = $AudioStreamPlayer  # drag your .mp3, .wav, or .ogg here

func _ready():
	add_child(tween)
	target.rect_position = Vector2(0, 0)
	

func _input(event):
	if event.is_action_pressed("ui_accept"):  # Space bar
		flash_and_sound()

func flash_and_sound():
	target.show()
	sound.stop()  # in case it was playing before
	sound.play()  # start from beginning

	var original_color = target.color
	var flash_color = Color(1, 1, 1)
	var half = 0.1
	tween.stop_all()
	tween.interpolate_property(target, "color", original_color, flash_color, half,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.interpolate_property(target, "color", flash_color, original_color, half,
		Tween.TRANS_SINE, Tween.EASE_IN, half)
	tween.start()

	# Hide after flash, but let sound finish
	yield(tween, "tween_all_completed")
	target.hide()
