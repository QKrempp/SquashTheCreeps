extends CharacterBody3D

signal hit
signal reset_streak

@export var speed = 14

@export var fall_acceleration = 75

@export var jump_impulse = 20

@export var bounce_impulse = 16

@export var rotation_speed = 10

var target_velocity = Vector3.ZERO

var airborn = false

func _physics_process(delta: float) -> void:
	
	var direction = Vector3.ZERO
	

	#if Input.is_action_pressed("move_back") or Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		#var input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.5)
		#direction.x = input_direction.x
		#direction.z = input_direction.y
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		#$Pivot.basis = Basis.looking_at(direction)
		$Pivot.basis = $Pivot.basis.slerp(Basis.IDENTITY.looking_at(direction), delta * rotation_speed)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	else:
		if airborn:
			reset_streak.emit()
		airborn = false
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play()
		target_velocity.y = 0
	
		
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
		airborn = true
		$AnimationPlayer.pause()
		
	for index in range(get_slide_collision_count()):
		
		var collision: KinematicCollision3D = get_slide_collision(index)
		
		if collision.get_collider() == null:
			continue
			
		if collision.get_collider().is_in_group("mob"):
			
			var mob = collision.get_collider()
		
			if Vector3.UP.dot(collision.get_normal()) > 0.2:
				mob.squash()
				target_velocity.y = bounce_impulse
				Input.start_joy_vibration(0, 0.4, 0.5, 0.2)
				break
	
	velocity = target_velocity
	
	$Pivot.rotation.x = (PI/6) * (velocity.y / jump_impulse)
	
	move_and_slide()


func die() -> void:
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body: Node3D) -> void:
	die()
