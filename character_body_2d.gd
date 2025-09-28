extends CharacterBody2D

@export var speed = 200
@onready var anim_sprite = $AnimatedSprite2D

func get_input():
	
	look_at(get_global_mouse_position())
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	if velocity != Vector2.ZERO:
		anim_sprite.play("default")
	else:
		anim_sprite.stop()

func _physics_process(delta):
	get_input()
	move_and_slide()
