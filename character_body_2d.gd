extends CharacterBody2D

var direction: float =0.0
var speed: float= 1000.0

func _ready():
	rotation=direction
	
func _physics_process(delta):
	velocity= Vector2(speed,0).rotated(direction)
	move_and_slide()
