extends KinematicBody2D

export var speed = 220
export var jump_force = 380
export var gravity = 980

var velocity = Vector2.ZERO

onready var animated_sprite = $AnimatedSprite

func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta

	# Horizontal movement
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed

	# Jump
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = -jump_force

	# Flip sprite
	if velocity.x < 0:
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.flip_h = false

	# Animation logic
	if animated_sprite:
		if not is_on_floor():
			animated_sprite.play("jump")
		elif abs(velocity.x) > 30:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")

	# Interact input
	if Input.is_action_just_pressed("interact"):
		var chat_ui = get_tree().current_scene.get_node("ChatUI")
		if chat_ui:
			chat_ui.start_chat([
				"Hello traveler...",
				"This world is full of darkness.",
				"What are you looking for?"
			])
		else:
			print("ChatUI not found!")

	# Move the character
	velocity = move_and_slide(velocity, Vector2.UP)
