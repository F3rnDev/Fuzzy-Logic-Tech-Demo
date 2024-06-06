extends CharacterBody3D
class_name Player

@export var lbl:Label
@export var SPEED = 3
var MIN_SPEED = 0
var MAX_SPEED = SPEED*2

@export var acceleration:float = 10
@export var deceleration:float = 10
var targetSpeed
var curSpeed

var crouching = false
var running = false

var noiseAmount = 0
var playerStatus = "Normal"

func _physics_process(delta):
	setPlayerMovStatus()
	movePlayer(delta)
	updateText()

	move_and_slide()

func updateText():	
	lbl.text = "Status do Player: " + playerStatus + "\nBarulho: " + str(noiseAmount) + "%"

func movePlayer(delta):	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * targetSpeed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * targetSpeed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, deceleration * delta)
	
	var speed_magnitude = sqrt(velocity.x * velocity.x + velocity.z * velocity.z)
	noiseAmount = ((speed_magnitude - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)) * 100.0
	noiseAmount = round(clamp(noiseAmount, 0, 100))

func setPlayerMovStatus():
	crouching = Input.is_action_pressed("crouch")
	running = Input.is_action_pressed("run")
	
	targetSpeed = SPEED
	playerStatus = "Normal"
	
	if crouching and !running:
		playerStatus = "Crouching"
		targetSpeed /= 2
		
	elif !crouching and running:
		playerStatus = "Running"
		targetSpeed *= 2
		
	elif crouching and running:
		playerStatus = "Crouch Running"
		targetSpeed /= 1.5
