extends CanvasLayer

signal chat_finished

var api_key =  Autoload.get_key()

onready var close_button = $Panel/CloseChat
onready var send_message = $Panel/SendChat
onready var user_input = $Panel/UserInput
onready var chat_log = $Panel/Chat_Log
onready var http_request = $HTTPRequest

func _ready():
	hide()
	
	close_button.connect("pressed", self, "end_chat")
	send_message.connect("pressed", self, "_on_send_pressed")
	user_input.connect("text_entered", self, "_on_text_entered")
	http_request.connect("request_completed", self, "_on_request_completed")

func start_chat(message_list = []):
	show()
	chat_log.clear()
	
	# Show optional starter NPC lines
	for msg in message_list:
		chat_log.append_bbcode("\n[color=green]NPC:[/color] " + msg)

func _on_text_entered(_new_text):
	_on_send_pressed()

func _on_send_pressed():
	var message = user_input.text.strip_edges()
	if message == "":
		return
	
	chat_log.append_bbcode("\n[color=cyan]You:[/color] " + message)
	user_input.text = ""
	
	send_to_ai(message)

# ─────────────────────────────────────────────
# Send to OpenRouter (simple - no history)
# ─────────────────────────────────────────────
func send_to_ai(user_message: String):
	var url = "https://openrouter.ai/api/v1/chat/completions"
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key,
		"HTTP-Referer: https://yourgame.com",
		"X-Title: Godot RPG Chat"
	]
	
	var body = {
		"model": "baidu/cobuddy:free",
		"messages": [
			{
				"role": "user",
				"content": user_message
			}
		]
	}
	
	var json_body = JSON.print(body)
	
	print("🔥 Sending request...")
	var error = http_request.request(url, headers, true, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		chat_log.append_bbcode("\n[color=red]Failed to start request[/color]")

func _on_request_completed(result, response_code, headers, body):
	print("📡 Response code: ", response_code)
	
	var response_text = body.get_string_from_utf8()
	print("📦 Raw response: ", response_text)
	
	if response_code != 200:
		chat_log.append_bbcode("\n[color=red]HTTP Error: " + str(response_code) + "[/color]")
		return
	
	var json = JSON.parse(response_text)
	if json.error != OK:
		chat_log.append_bbcode("\n[color=red]JSON Parse Error[/color]")
		return
	
	var data = json.result
	if data.has("choices") and data["choices"].size() > 0:
		var reply = data["choices"][0]["message"]["content"]
		chat_log.append_bbcode("\n[color=green]NPC:[/color] " + reply)
	else:
		chat_log.append_bbcode("\n[color=red]No reply from AI[/color]")

func end_chat():
	hide()
	emit_signal("chat_finished")
