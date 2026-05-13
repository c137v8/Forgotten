extends CanvasLayer

signal chat_finished

var messages = []
var current_index = 0

onready var text_label = $Panel/RichTextLabel
onready var next_button = $Panel/Button

func _ready():
	hide()  # Hide by default

# Call this to start a conversation
func start_chat(message_list):
	messages = message_list
	current_index = 0
	show()
	show_next_message()

func show_next_message():
	if current_index >= messages.size():
		end_chat()
		return
	
	text_label.bbcode_text = messages[current_index]
	current_index += 1

func end_chat():
	hide()
	emit_signal("chat_finished")

func _on_Button_pressed():
	show_next_message()
