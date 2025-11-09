extends CanvasLayer

onready var tween = Tween.new()
onready var sound: AudioStreamPlayer = $AudioStreamPlayer
onready var forgotten: TextureRect = $forgotten

var has_played = false   # prevents retriggering on subsequent space presses
const START_VOL_DB = -40 # start almost silent
const TARGET_VOL_DB = 0  # target loudness
const FADE_TIME = 1.2    # fade-in duration for audio (seconds)
const IMAGE_FADE_TIME = 4.0  # slow fade-in for the TextureRect (seconds)

func _ready():
	add_child(tween)
	# ensure the image is present and starts invisible (alpha = 0)
	if forgotten:
		forgotten.show()
		var c = forgotten.modulate
		c.a = 0.0
		forgotten.modulate = c

	# connect finished to loop the sound when it ends
	if sound:
		sound.connect("finished", self, "_on_sound_finished")

func _input(event):
	if event.is_action_pressed("ui_accept") and not has_played:
		has_played = true
		play_sound_with_fade_and_image()

func play_sound_with_fade_and_image():
	if not sound or not sound.stream:
		print("No AudioStreamPlayer or stream assigned.")
		return

	# Prepare sound: start from silent and play
	sound.stop()
	sound.volume_db = START_VOL_DB
	sound.play()

	# Start/queue tweens: audio fade + image alpha fade
	tween.stop_all()

	# audio fade
	tween.interpolate_property(sound, "volume_db",
		START_VOL_DB, TARGET_VOL_DB, FADE_TIME,
		Tween.TRANS_SINE, Tween.EASE_OUT)

	# image fade (modulate:a) from 0 -> 1
	if forgotten:
		# ensure the image is visible (alpha controls actual visibility)
		forgotten.show()
		# set initial alpha explicitly (in case)
		var c = forgotten.modulate
		c.a = 0.0
		forgotten.modulate = c

		# Tween the alpha channel
		tween.interpolate_property(forgotten, "modulate:a",
			0.0, 1.0, IMAGE_FADE_TIME,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)

	tween.start()

# Called when the audio finishes playing — restart to loop
func _on_sound_finished():
	# simply restart playing (keeps current volume db)
	if sound:
		sound.play()
