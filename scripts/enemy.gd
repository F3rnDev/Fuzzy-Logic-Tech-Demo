extends CharacterBody3D

signal sawPlayer


@onready var agent = $NavigationAgent3D

@export var cameraRef:Camera3D

@export var minDistance:float
@export var player:Player

@export var normalColor:Color
@export var collColor:Color
var curCollColor

var curDistance
var toogleColl = false

var noiseLookAt
var noisePosition

var startScanTimer:Timer
var changeScanRotTimer:Timer
var backToPatrolTimer:Timer
var patrolTimer:Timer

@export_enum("Patrol", "Alert", "GoingToScan", "Scanning") var curState:String = "Patrol"
@export var rotateAmount:float

var randomLookDir = null

@export var activatePatrol = true

func _ready():
	curCollColor = normalColor
	noisePosition = position
	noiseLookAt = global_transform.origin
	curState = "Patrol"
	
	for ray in $Raycast.get_children():
		ray.target_position.z = -minDistance


func checkDistance() -> bool:
	curDistance = global_position.distance_to(player.global_position)
	
	if curDistance < minDistance:
		return true
	
	return false

func _process(delta):
	$raycastLines.queue_redraw()
	
	var ableToHear = checkDistance()
	
	#set coll color
	curCollColor = normalColor if ableToHear else collColor
	changeCollColor()
	
	#set fuzzy logic (start with "if ableToHear:")
	if ableToHear and player.noiseAmount > 0.0:
		fuzzyHear()
	
	#navMeshMovement
	if global_position.distance_to(agent.target_position) > 0.5 and curState != "Alert":
		var curLocation = global_transform.origin
		var nextLocation = agent.get_next_path_position()
		
		if not curLocation.is_equal_approx(nextLocation):
			var curVelocity = (nextLocation - curLocation).normalized() * 1.0
			velocity = velocity.move_toward(curVelocity, 3.0)

			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * rotateAmount)
		else:
			velocity = Vector3.ZERO
	else:
		velocity = Vector3.ZERO
	
	#enemyStates
	match curState:
		"Patrol":
			patrol()
		"Alert":
			Alert(delta)
		"GoingToScan":
			GoToNoisePosition()
		"Scanning":
			scanSurroundings(delta)
	
	move_and_slide()
	
	for ray in $Raycast.get_children():
		if ray.get_collider() == player:
			sawPlayer.emit()

#fuzzyLogic
func fuzzyHear():
	#fuzzifica as váriaveis da distância e barulho
	var fuzzyDist = Distance.fuzzify(curDistance)
	var fuzzyNoise = FzyNoise.fuzzify(player.noiseAmount)
	
	#aplica a inferência e retorna a váriavel fuzzificada do resultado
	var fuzzyResult = InferenceSystem.calculate(fuzzyDist, fuzzyNoise)
	
	#deffuzifica o resultado
	var deffuzyResult = Deffuzyfier.deffuzify(fuzzyResult)
	
	#checa o resultado defuzzificado
	if deffuzyResult >= 55.0:
		print("Escutei o jogador")
		
		noisePosition = player.global_position
		noiseLookAt = player.transform.origin
		curState = "Alert"
#------------------------------------------------

#---Behaviour---
func getRandomTarget(radius):
	var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var random_distance = randf_range(0, radius)
	return global_transform.origin + random_direction * random_distance

#Alert:
func Alert(delta) -> void:
	#reset Timers
	if backToPatrolTimer:
		backToPatrolTimer.queue_free()
		backToPatrolTimer = null
	
	if changeScanRotTimer:
		changeScanRotTimer.queue_free()
		changeScanRotTimer = null
	#END
	
	
	agent.target_position = global_position
	var target_position = noiseLookAt
	var new_transform = transform.looking_at(target_position, Vector3.UP)
	transform = transform.interpolate_with(new_transform, rotateAmount * delta)

	rotation.x = 0
	rotation.z = 0
	
	var direction_to_target = (target_position - global_transform.origin).normalized()
	var forward_direction = transform.basis.z.normalized()
	if direction_to_target.dot(forward_direction) < 0.0:
		waitToScan()

func waitToScan():
	if !startScanTimer:
		startScanTimer = Timer.new()
		startScanTimer.wait_time = 1.5
		startScanTimer.timeout.connect(startScan)
		add_child(startScanTimer)
		startScanTimer.start()
#END

#Go to scan:
func startScan():
	curState = "GoingToScan"
	if startScanTimer:
		startScanTimer.queue_free()
		startScanTimer = null

func GoToNoisePosition():
	agent.target_position = noisePosition
	if agent.is_navigation_finished():
		curState = "Scanning"
#

#Scanning
func scanSurroundings(delta):
	#start timer
	if !changeScanRotTimer:
		changeScanRotTimer = Timer.new()
		changeScanRotTimer.wait_time = 2.0
		changeScanRotTimer.timeout.connect(lookForPlayer)
		add_child(changeScanRotTimer)
		changeScanRotTimer.start()
	#END
	
	if randomLookDir != null:
		var new_transform = transform.looking_at(randomLookDir, Vector3.UP)
		transform = transform.interpolate_with(new_transform, rotateAmount * delta)

		rotation.x = 0
		rotation.z = 0

func lookForPlayer():
	#reset/start Timers
	if !backToPatrolTimer:
		backToPatrolTimer = Timer.new()
		backToPatrolTimer.wait_time = 8.0
		backToPatrolTimer.timeout.connect(resetToPatrol)
		add_child(backToPatrolTimer)
		backToPatrolTimer.start()
	
	if changeScanRotTimer:
		changeScanRotTimer.queue_free()
		changeScanRotTimer = null
	#END
	
	randomLookDir = getRandomTarget(10.0)
#END

#Patrol:
func resetToPatrol():
	#reset Timers
	if backToPatrolTimer:
		backToPatrolTimer.queue_free()
		backToPatrolTimer = null
	
	if changeScanRotTimer:
		changeScanRotTimer.queue_free()
		changeScanRotTimer = null
	#END
	
	randomLookDir = null
	curState = "Patrol"

func patrol():
	if !patrolTimer and activatePatrol:
		patrolTimer = Timer.new()
		patrolTimer.wait_time = 5.0
		patrolTimer.timeout.connect(goToNewPos)
		add_child(patrolTimer)
		patrolTimer.start()
	
#	if patrolTimer != null:
#		print(patrolTimer.time_left)

func goToNewPos():
	if patrolTimer:
		patrolTimer.queue_free()
		patrolTimer = null
	
	agent.target_position = getRandomTarget(2.0)

#------------------------------------------------

#DEBUG
func changeCollColor():
	var existingSphereMesh = find_child("drawHearRadius", true, false)
	
	if existingSphereMesh != null:
		var transparent_material = StandardMaterial3D.new()
		transparent_material.albedo_color = curCollColor
		transparent_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		transparent_material.flags_transparent = true
		
		existingSphereMesh.mesh.surface_set_material(0, transparent_material)

func showCollider(value):
	toogleColl = value
	
	var existingSphereMesh = find_child("drawHearRadius", true, false)
	
	if toogleColl and existingSphereMesh == null:
		var circle_instance = MeshInstance3D.new()
		circle_instance.name = "drawHearRadius"

		var cylinder_mesh = SphereMesh.new()
		cylinder_mesh.radius = minDistance
		
		var transparent_material = StandardMaterial3D.new()
		transparent_material.albedo_color = curCollColor
		transparent_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		transparent_material.flags_transparent = true
		
		cylinder_mesh.surface_set_material(0, transparent_material)
		circle_instance.mesh = cylinder_mesh
		
		add_child(circle_instance)
	elif existingSphereMesh != null:
		remove_child(existingSphereMesh)
#


func _on_raycast_lines_draw():
	for ray in $Raycast.get_children():
		var color = Color(0, 1, 0)
		var start = cameraRef.unproject_position(ray.global_transform.origin)
		
		var endPos
		if ray.is_colliding():
			endPos = ray.get_collision_point()
			color = Color(1, 0, 0)
		else:
			endPos = ray.global_transform.origin + (ray.global_transform.basis * ray.target_position)
		
		var end = cameraRef.unproject_position(endPos)
		$raycastLines.draw_line(start, end, color, 1.0)
		$raycastLines.draw_circle(end, 5.0, color)
