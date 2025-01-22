extends CharacterBody3D

signal hit
signal clear

@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var sens = 0.5
@onready var pivot = $CameraOrigin
var target_velocity = Vector3.ZERO
var crouched = false;

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _physics_process(delta):
	# check for each move input and update the direction accordingly.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if Input.is_action_just_pressed("crouch"):
		toggle_crouch()
	# Vertical Velocity
	if not is_on_floor():
		velocity.y = velocity.y - (fall_acceleration * delta)
		#print(target_velocity.y)
		
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		if crouched:
			toggle_crouch()
			velocity.y = jump_impulse * 2
		else:
			velocity.y = jump_impulse
	else:
		if is_on_floor():
			velocity.y = 0

	
	move_and_slide()
	
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)

		# If the collision is with ground
		if collision.get_collider() == null:
			continue

		# If the collider is with a hazard
		if collision.get_collider().is_in_group("Hazard"):
			die()
			break
		
		if collision.get_collider().is_in_group("Goal"):
			clear.emit()
			break

func die():
	hit.emit()
	queue_free()
	
func toggle_crouch():
	if crouched:
		if !collides_on_uncrouch():
			crouched = false
			$CollisionShape3D.scale.y *= 2
			$MeshInstance3D.scale.y *= 2
			$CollisionShape3D.scale.x *= 0.5
			$MeshInstance3D.scale.x *= 0.5
			$CollisionShape3D.scale.z *= 0.5
			$MeshInstance3D.scale.z *= 0.5
			
	else:
		crouched = true
		$CollisionShape3D.scale.y *= 0.5
		$MeshInstance3D.scale.y *= 0.5
		$CollisionShape3D.scale.x *= 2
		$MeshInstance3D.scale.x *= 2
		$CollisionShape3D.scale.z *= 2
		$MeshInstance3D.scale.z *= 2
		
		
func collides_on_uncrouch() -> bool:
	var upwards_offset = 2;
	var collision = move_and_collide(Vector3(0,upwards_offset,0),true)
	
	if collision:
		print("object above")
		return true;
		
	return false
