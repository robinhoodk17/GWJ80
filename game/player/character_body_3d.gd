extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 2.25
var direction : Vector2
var fly : bool
func update(delta) -> void:
	if not is_on_floor() and !fly:
		velocity += get_gravity() * delta
	if fly:
		velocity.y = JUMP_VELOCITY
	if direction:
		var looking_at : Vector3 = Vector3(direction.x, 0, direction.y)
		velocity.x = direction.x * SPEED
		velocity.z = direction.y * SPEED
		$Pivot.basis = Basis.looking_at(looking_at.normalized())
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
