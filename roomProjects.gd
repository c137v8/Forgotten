extends Area2D

export(NodePath) var camera_path
onready var camera = get_node(camera_path) as Camera2D
onready var collision_shape = $CollisionShape2D

func _ready():
	var _err = connect("body_entered", self, "_on_Room_body_entered")

func _on_Room_body_entered(body):
	if body.is_in_group("player"):
		if camera == null:
			return
		
		# Calculate the target room boundaries
		var shape = collision_shape.shape as RectangleShape2D
		var extents = shape.extents
		var center = collision_shape.global_position
		
		var target_left = center.x - extents.x
		var target_right = center.x + extents.x
		var target_top = center.y - extents.y
		var target_bottom = center.y + extents.y
		
		# --- THE PREMIUM CAMERA GLIDE ---
		# Create a fresh, parallel tween engine (Godot 3.5+)
		var tween = create_tween().set_parallel(true)
		
		# TRANS_CUBIC + EASE_OUT gives it a swift start and a graceful deceleration
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		
		# Animate all 4 boundaries simultaneously over 0.5 seconds
		tween.tween_property(camera, "limit_left", target_left, 0.5)
		tween.tween_property(camera, "limit_right", target_right, 0.5)
		tween.tween_property(camera, "limit_top", target_top, 0.5)
		tween.tween_property(camera, "limit_bottom", target_bottom, 0.5)
