extends CharacterBody3D

signal squashed

@export var min_speed: int = 10

@export var max_speed: int = 18

func _physics_process(delta: float) -> void:
	move_and_slide()
	
func initialize(start_position: Vector3, player_position: Vector3) -> void:
	#print("==> Initializing mob")
	look_at_from_position(start_position, player_position, Vector3.UP)
	#print(rotation)
	rotation.x = 0
	rotation.z = 0
	rotate_y(randf_range(-PI/8, PI/8))
	var random_speed: int = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	#print(rotation)

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()

func squash():
	$AnimationPlayer.play("squashed")
	velocity = Vector3.ZERO
	await get_tree().create_timer(0.3).timeout
	squashed.emit()
	queue_free()
