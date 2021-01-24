extends KinematicBody2D

# state machine
enum states{IDLE, CROUCH, WALK, WALK_END, 
DASH_START, DASH, DASH_END, PUNCH}
var state_to_str = {states.IDLE: 'IDLE',
					states.CROUCH: 'WALK_START',
					states.WALK: 'WALK',
					states.WALK_END: 'WALK_END',
					states.DASH_START: 'DASH_START',
					states.DASH: 'DASH',
					states.DASH_END: 'DASH_END',
					states.PUNCH: 'PUNCH'}
var pstate = null

# general movement
var velocity = Vector2.ZERO

# vertical movement
const JUMP_IMPULSE = 1000
const GRAVITY = 2000

# horizontal movement
var STICK_BUFFER_SIZE = 3
var stick_buffer = []
const SPEED = 350
const DASH_SPEED = 700
const HEAVY_INP_THRESHOLD = 0.7

#jumps
const MAX_JUMPS = 2
var jumps_remaining = MAX_JUMPS

# spawning and lives
var player_index = null
const MAX_LIVES = 3
var spawn_loc
var lives

var animation_state_machine

func local_action_name(a: String) -> String:
	return a + '_' + str(player_index)

func _ready():
	animation_state_machine = $AnimationTree.get('parameters/playback')
	set_state_and_animation(states.IDLE)
	for _i in range(STICK_BUFFER_SIZE):
		stick_buffer.append(Vector2())
	hide()

func set_lives(n):
	lives = n
	
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
	elif event.is_action_pressed(local_action_name('attack')):
		animation_state_machine.travel('punch')

func set_state_and_animation(state):
	pstate = state
	animation_state_machine.travel(state_to_str[state])

var input_vector = Vector2.ZERO
func process_input() -> void:
	input_vector.x = Input.get_action_strength(local_action_name('move_right'))
	input_vector.x -= Input.get_action_strength(local_action_name('move_left'))
	input_vector.y = Input.get_action_strength(local_action_name('move_down'))
	# print(str(player_index) + '_' + str(input_vector))

	stick_buffer.append(input_vector)
	stick_buffer.pop_front()

	# left/right
	var earliest = stick_buffer.front().x
	var latest = stick_buffer.back().x
	var earliest_is_centered = earliest == 0
	# var earliest_is_light = abs(earliest =) < H_INP_THRESHOLD and abs(earliest =) > 0
	# var earliest_is_heavy = abs(earliest =) >= HEAVY_INP_THRESHOLD
	var latest_is_centered = latest == 0
	var latest_is_light = abs(latest) < HEAVY_INP_THRESHOLD and abs(latest) > 0
	var latest_is_heavy = abs(latest) >= HEAVY_INP_THRESHOLD
	
	var dash_ok = earliest_is_centered and latest_is_heavy and is_on_floor()

	match pstate:
		states.IDLE:
			if dash_ok:
				set_state_and_animation(states.DASH)
			elif latest_is_light or latest_is_heavy:
				set_state_and_animation(states.WALK)
		states.WALK:
			if dash_ok:
				set_state_and_animation(states.DASH)
		states.DASH:
			if latest_is_light:
				set_state_and_animation(states.WALK)
		_:
			print('unknown current state')
	if latest_is_centered:
		set_state_and_animation(states.IDLE)
	
func _physics_process(_delta):
	process_input()	

func _process(delta):
	if pstate == states.DASH:
		velocity.x = input_vector.normalized().x * DASH_SPEED
	elif pstate == states.WALK:
		velocity.x = input_vector.x * SPEED
	else:
		velocity.x -= velocity.x * 0.2

	var effective_gravity = GRAVITY
	if velocity.y > 0:
		effective_gravity += GRAVITY * 3 * input_vector.y
	velocity.y += effective_gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP)

	$Body/Sprite.flip_h = velocity.x < 0
	
	if is_on_floor():
		jumps_remaining = max(jumps_remaining, MAX_JUMPS)
	elif jumps_remaining == MAX_JUMPS:
		jumps_remaining -= 1
