extends Node2D

var enemy = preload("res://enemy.tscn")

@onready var enemy_controller = get_node("EnemyController")

@onready var start_button = $CanvasLayer/CenterContainer/Start
@onready var game_over = $CanvasLayer/CenterContainer/GameOver

@onready var camera = $Camera2D


var rng = RandomNumberGenerator.new()
var DEFAULTSPRITESIZE = 64
var isGameActive = false
var score: float = 0
var time: float = 0

var i = 5
var filePath = OS.get_user_data_dir() + "/nonsas_data/"
#NOTE: You must press the X on the window instead of stopping the game so that the file will properly close.
var file = FileAccess.open(filePath + "Run " + str(i) + ".txt", FileAccess.WRITE)

func startGame() -> void:

	camera.zoom = Vector2.ONE * .1
	Engine.max_fps = 0

	isGameActive = true
	score = 0
	
	$Player.show()
	$Player.start()
	start_button.hide()
	game_over.hide()
	$CanvasLayer/UI.show()
	$CanvasLayer/UI.updateScore(score)

func endGame() -> void:
	isGameActive = false
	$Player.hide()
	get_tree().call_group("Enemies", "queue_free")
	game_over.show()	
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()
	
func getEnemyScaleFromRange(enemySizeRange: Vector2) -> Vector2:
	
	return Vector2.ONE * rng.randf_range(enemySizeRange.x, enemySizeRange.y)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.hide()
	start_button.show()
	game_over.hide()
	$CanvasLayer/UI.hide()

func writeToFile(currentTime, framerate, enemySize, enemyVelocity) -> void:
	var concatString = str("%2.3f" % currentTime) + ", " + str("%2.3f" % framerate) + "," + \
	str(enemySize) + "," + str(enemyVelocity) + "\n"

	file.store_var(concatString)

	#NOTE: # enemies and enemySight are fixed variables




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var spawnrate = enemy_controller.getNumEnemies()
	if !isGameActive:
		return
		
	if (time < 45):
		if (time > 15):
			var enemySize = enemy_controller.getEnemySize()
			var enemyVelocity = enemy_controller.getEnemyVelocity()
			writeToFile(time, Engine.get_frames_per_second(), enemySize, enemyVelocity)
		time += delta
	else:
		print("Times up")

	
	if rng.randf() < spawnrate * delta:
		#print("Spawning an Enemy")
		var e = enemy.instantiate()
		e.scale = getEnemyScaleFromRange(enemy_controller.getEnemySize())
		add_child(e)
		#print("Created new enemy")


func _on_player_ate_enemy(area : Area2D) -> void:
	score += area.scale.length() * DEFAULTSPRITESIZE 
	$CanvasLayer/UI.updateScore(score)
	
func get_score() -> float:
	return score
