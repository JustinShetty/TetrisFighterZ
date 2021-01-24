extends KinematicBody2D

signal updated_move_state
signal lives_updated

var velocity = Vector2.ZERO
const JUMP_IMPULSE = 1000
const GRAVITY = 2000

var LR_BUFFER_SIZE = 3
var x_buffer = []
const SPEED = 350
const DASH_SPEED = 700
const HARD_INP_THRESHOLD = 0.7

enum ms{IDLE, WALK, DASH}
var move_state = ms.IDLE
const MAX_JUMPS = 2
var jumps_remaining = MAX_JUMPS

const MAX_LIVES = 3
var spawn_loc
var lives

var player_index = null

func local_action_name(a: String) -> String:
	return a + '_' + str(player_index)

func _ready():
	for _i in range(LR_BUFFER_SIZE):
		x_buffer.append(0)
	hide()

func set_lives(n):
	lives = n
	emit_signal('lives_updated')
	
func start(idx, pos):
	player_index = idx
	spawn_loc = pos
	position = spawn_loc
	set_lives(MAX_LIVES)
	show()
	
func _on_VisibilityNotifier2D_screen_exited():
	set_lives(lives - 1)
	position = spawn_loc

func _input(event):
	if event.is_action_pressed(local_action_name('jump')) and jumps_remaining > 0:
		velocity.y = -JUMP_IMPULSE
		jumps_remaining -= 1
	elif event.is_action_pressed(local_action_name('punch')):
		print('punch')

var input_vector = Vector2.ZERO

func process_input() -> void:
	var input_suffix = '_' + str(player_index)
	input_vector.x = Input.get_action_strength(local_action_name('move_right'))
	input_vector.x -= Input.get_action_strength(local_action_name('move_left'))
	input_vector.y = Input.get_action_strength(local_action_name('move_down'))

	x_buffer.append(input_vector.x)
	x_buffer.pop_front()

	var earliest_is_centered = x_buffer.front() == 0
	# var earliest_is_light = abs(x_buffer.front()) < HARD_INP_THRESHOLD and abs(x_buffer.front()) > 0
	# var earliest_is_heavy = abs(x_buffer.front()) >= HARD_INP_THRESHOLD
	var latest_is_centered = x_buffer.back() == 0
	var latest_is_light = abs(x_buffer.back()) < HARD_INP_THRESHOLD and abs(x_buffer.back()) > 0
	var latest_is_heavy = abs(x_buffer.back()) >= HARD_INP_THRESHOLD
	
	var dash_ok = earliest_is_centered and latest_is_heavy and is_on_floor()

	match move_state:
		ms.IDLE:
			if dash_ok:
				move_state = ms.DASH
			elif latest_is_light or latest_is_heavy:
				move_state = ms.WALK
		ms.WALK:
			if dash_ok:
				move_state = ms.DASH
			elif latest_is_centered:
				move_state = ms.IDLE
		ms.DASH:
			if latest_is_light:
				move_state = ms.WALK
			elif latest_is_centered:
				move_state = ms.IDLE

	emit_signal('updated_move_state')
	
func _physics_process(_delta):
	process_input()	

func _process(delta):
	if move_state == ms.DASH:
		velocity.x = input_vector.normalized().x * DASH_SPEED
	elif move_state == ms.WALK:
		velocity.x = input_vector.x * SPEED
	else:
		velocity.x -= velocity.x * 0.2

	var effective_gravity = GRAVITY
	if velocity.y > 0:
		effective_gravity += GRAVITY * 3 * input_vector.y
	velocity.y += effective_gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		jumps_remaining = max(jumps_remaining, MAX_JUMPS)
	elif jumps_remaining == MAX_JUMPS:
		jumps_remaining -= 1
