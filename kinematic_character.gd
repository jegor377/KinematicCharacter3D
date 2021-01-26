class_name KinematicCharacter
extends KinematicBody


const GRAVITY := 9.8
const VELOCITY_DAMP := 1.9
const MIN_DYN_VEL := 0.5

var dynamic_velocity: Vector3
var gravity_velocity: Vector3
var static_velocity: Vector3


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	apply_dyn_vel_damp(delta)
	
	_manipulate_velocities(delta)
	
	if dynamic_velocity.length() < MIN_DYN_VEL:
		dynamic_velocity = Vector3.ZERO
	
	var collision: KinematicCollision = move_and_collide((dynamic_velocity + gravity_velocity + static_velocity) * delta)
	if collision != null:
		_handle_collision(collision, delta)


func apply_gravity(delta: float) -> void:
	gravity_velocity += Vector3.DOWN * GRAVITY * delta
	if will_collide_with_floor((dynamic_velocity + gravity_velocity) * delta):
		gravity_velocity = Vector3.ZERO
		dynamic_velocity.y = 0

func apply_dyn_vel_damp(delta: float) -> void:
	dynamic_velocity -= dynamic_velocity * VELOCITY_DAMP * delta

func apply_impulse(velocity: Vector3) -> void:
	dynamic_velocity += velocity

func _manipulate_velocities(delta: float) -> void:
	pass

func _handle_collision(collision: KinematicCollision, delta: float) -> void:
	pass

func will_collide_with_floor(movement: Vector3) -> bool:
	return false

func bounce(direction: Vector3, absorption: float = 0.83) -> void:
	dynamic_velocity = direction * dynamic_velocity.length() * (1.0 - absorption)
