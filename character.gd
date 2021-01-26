class_name Player
extends KinematicCharacter


const MOVING_VELOCITY := 1.0
const JUMP_VELOCITY := 10.0
const DASH_VELOCITY := 8.0

export(NodePath) var spawn_pos
export(NodePath) var fall_point

var is_moving_left := false
var is_moving_right := false
var is_moving_forward := false
var is_moving_backward := false
var last_direction := Vector3.ZERO

onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree['parameters/playback']


func _process(delta):
	$AnimationTree['parameters/conditions/is_falling'] = gravity_velocity.length() > 0 and not is_on_ground()
	$AnimationTree['parameters/conditions/is_not_falling'] = not $AnimationTree['parameters/conditions/is_falling']
	$AnimationTree['parameters/conditions/is_moving'] = static_velocity.length() > 0.0
	$AnimationTree['parameters/conditions/is_not_moving'] = not $AnimationTree['parameters/conditions/is_moving']
	if translation.y < get_node(fall_point).translation.y:
		translation = get_node(spawn_pos).translation

func _input(event):
	if event.is_action_pressed("ui_left"):
		is_moving_left = true
	elif event.is_action_released("ui_left"):
		is_moving_left = false
	if event.is_action_pressed("ui_right"):
		is_moving_right = true
	elif event.is_action_released("ui_right"):
		is_moving_right = false
	if event.is_action_pressed("ui_up"):
		is_moving_forward = true
	elif event.is_action_released("ui_up"):
		is_moving_forward = false
	if event.is_action_pressed("ui_down"):
		is_moving_backward = true
	elif event.is_action_released("ui_down"):
		is_moving_backward = false
	if event.is_action_released("ui_select"):
		state_machine.travel("Jump")
	if event.is_action_released("dash"):
		apply_impulse(last_direction * DASH_VELOCITY)

func _manipulate_velocities(delta: float) -> void:
	var final_direction := Vector3.ZERO
	if is_moving_left:
		final_direction += Vector3.LEFT + Vector3.BACK
	if is_moving_right:
		final_direction += Vector3.RIGHT + Vector3.FORWARD
	if is_moving_forward:
		final_direction += Vector3.FORWARD - Vector3.RIGHT
	if is_moving_backward:
		final_direction += Vector3.BACK - Vector3.LEFT
	if final_direction != Vector3.ZERO:
		last_direction = final_direction
	rotation.y = atan2(last_direction.x, last_direction.z)
	if state_machine.get_current_node() == 'Jump':
		final_direction = Vector3.ZERO
	static_velocity = final_direction * MOVING_VELOCITY

func _handle_collision(collision: KinematicCollision, delta: float) -> void:
	if collision.collider.is_in_group('Fence') and dynamic_velocity.length() > 0:
		bounce(collision.normal, 0.5)

func will_collide_with_floor(movement: Vector3) -> bool:
	return test_move(transform, movement) and is_on_ground()

func is_on_ground() -> bool:
	return $RayCast.is_colliding() and $RayCast.get_collider().is_in_group('Floor')


func _on_jumped() -> void:
	apply_impulse(Vector3.UP * JUMP_VELOCITY)
