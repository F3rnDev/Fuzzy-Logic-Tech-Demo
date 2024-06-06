extends Node3D

var selectedEnemy
var debug = false
var isGameOver = false

@export var setDebugOnStart = false

func _ready():
	Engine.time_scale = 1.0
	$gameOverScreen/gameOver.visible = false
	
	for enemy in range($enemyGrp.get_child_count()):
		$UI/enemyOpt.add_item("Inimigo " + str(enemy))
		
		$enemyGrp.get_child(enemy).sawPlayer.connect(gameOver)
	
	selectedEnemy = $enemyGrp.get_child(0)
	
	setDebug(setDebugOnStart)

func _process(delta):
	var curDist = 5.0
	var curNoise = $player.noiseAmount
	
	if selectedEnemy.checkDistance():
		curDist = clamp(selectedEnemy.global_position.distance_to($player.global_position), 0, 5)
		
		#update result
		$UI/graphic_res.dist = curDist
		$UI/graphic_res.noise = curNoise
	
	#update graphic distance
	$UI/graphic_dist.dist = curDist
	
	#update graphic noise
	$UI/graphic_noise.noise = curNoise
	
	#setEnemyStatus
	$UI/enemyInfo.text = "Status do Inimigo: " + selectedEnemy.curState

func _input(event):
	if event is InputEventKey and event.pressed and event.echo == false and event.keycode == KEY_F1:
		setDebug()
	
	if event is InputEventKey and event.pressed and event.echo == false and event.keycode == KEY_R:
		gameOver(true)

func setDebug(value=null):
	if value == null:
		debug = !debug
	else:
		debug = value

	selectedEnemy.showCollider(debug)
	$UI/graphic_dist.visible = debug
	$UI/graphic_noise.visible = debug
	$UI/graphic_res.visible = debug
	$UI/enemyInfo.visible = debug
	$UI/enemyOpt.visible = debug

func _on_enemy_opt_item_selected(index):
	selectedEnemy.showCollider(false)
	selectedEnemy = $enemyGrp.get_child(index)
	setDebug(debug)

func gameOver(restart=false):
	if (!isGameOver and !debug) or restart:
		isGameOver = true
		Engine.time_scale = 0.0
		$gameOverScreen/gameOver.visible = true
