extends Node

class varInfo:
	var range: Vector2
	var minVal: float
	var maxVal: float
	var offset: float
	
var enemySizeInfo: varInfo = varInfo.new()
var enemyVelocityInfo: varInfo = varInfo.new()

var smoothing = false

var SIGMA = .05
#@export var numEnemies: int
#@export var enemySize : int
#@export var enemyVelocity: int
#@export var enemySight: int

@onready var main = get_parent()
@onready var frameRateController = main.get_node("FrameRateController")
@onready var player = main.get_node("Player")

var happiness: float# = frameRateController.happiness
	
func updateRange(varInfoContainer: varInfo): 
	var minVal: float = varInfoContainer.minVal
	var maxVal: float = varInfoContainer.maxVal
	
	var currentRange: Vector2 = varInfoContainer.range
	var updatedRange: Vector2 = currentRange + currentRange * SIGMA * (happiness - .6)
	
	if updatedRange.x < minVal:
		#print("Too low")
		var scale_factor = (minVal - currentRange.x) / (updatedRange.x - currentRange.x)
		updatedRange.x = minVal
		updatedRange.y = currentRange.y + (updatedRange.y - currentRange.y) * scale_factor
		
	if updatedRange.y > maxVal:
		#print("Too high")
		var scale_factor = (maxVal - currentRange.y) / (updatedRange.y - currentRange.y)
		updatedRange.y = maxVal
		updatedRange.x = currentRange.x + (updatedRange.x - currentRange.x) * scale_factor
	
	updatedRange.x = clamp(updatedRange.x, minVal, maxVal)
	updatedRange.y = clamp(updatedRange.y, minVal, maxVal)
	

func updateEnemySizeBounds(varInfoContainer: varInfo):
	var score = main.get_score()
	var playerSize = player.scale.x
	
	var decayFactor = 1.0 / (pow(score + 1.0, 1/3.0))  # Controls how fast the gap shrinks for lower bound
	var growthFactor = sqrt(score) / (sqrt(score) + 100.0)   # Controls how fast the gap grows for upper bound
	
	var lowerBoundEnemySize = playerSize - (playerSize * decayFactor) / 5.0  # Shrinking gap, smoother progression
	var upperBoundEnemySize = playerSize + (playerSize * growthFactor)  # Growing gap, but gradually

	enemySizeInfo = instantiateVarInfo(enemySizeInfo, lowerBoundEnemySize, upperBoundEnemySize)
	#print(Vector2(lowerBoundEnemySize, upperBoundEnemySize))
	return true
	
	
func instantiateVarInfo(varInfoContainer: varInfo, minVal: float, maxVal: float):
	var offset = (maxVal - minVal) * 1.0
	var quarteredOffset = offset / 4
	varInfoContainer.minVal = minVal
	varInfoContainer.maxVal = maxVal
	varInfoContainer.range = Vector2(minVal + quarteredOffset, maxVal - quarteredOffset)
	varInfoContainer.offset = offset
	
	return varInfoContainer

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	enemySizeInfo = instantiateVarInfo(varInfo.new(), 1, 10)
	enemyVelocityInfo = instantiateVarInfo(varInfo.new(), 50, 300)

func _process(_delta: float) -> void:
	updateEnemySizeBounds(enemySizeInfo)
	updateRange(enemySizeInfo)
	updateRange(enemyVelocityInfo)
		
	
func getVarVal(varInfoContainer: varInfo):
	return varInfoContainer.range
	
func getNumEnemies():
	return 2
	
func getEnemySize():
	return enemySizeInfo.range

func getEnemyVelocity():
	return enemyVelocityInfo.range

func getEnemySight():
	return 1000
