extends Node


#@onready var player = get_node("Player")
#@onready var vel = player.velocity
var framerate
var idealFramerate = 160.0
var minimumFramerate = 30.0

var minimumDynamicZoomFramerate = 60
var maximumDynamicZoomFramerate = 180
var minimumSmoothZoomFramerate = 24

var minZoom = 1
var zoom = 1

@export var happiness = 0.0

@onready var main = get_parent()
@onready var player = main.get_node("Player")
@onready var viewport = get_viewport()
#@onready var camera = main.get_node("Camera2D")

#Maybe I could get the default screen size and then multiply it by the zoom factor 

func update_framerate() -> float:
	framerate = Engine.get_frames_per_second()
	return framerate

func determineHappiness():
	
	#print(framerate)
	#print((framerate - minimumFramerate) / (idealFramerate - minimumFramerate))
	happiness = clamp((framerate - minimumFramerate) / (idealFramerate - minimumFramerate), 0, 1) 
	return happiness

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(main.get_viewport_rect().size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta) -> void:
	#update_framerate()
	#determineHappiness()
	#
