extends CharacterBody2D

@onready var anim_sprite = $AnimatedSprite2D

var speed := 200  # Velocidad de movimiento

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	# Movimiento con WASD o flechas
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	# Normalizar vector para que no corra más rápido en diagonal
	velocity = direction.normalized() * speed

	# Mueve al personaje con colisiones
	move_and_slide()
	
func _ready():
	anim_sprite.play("default")
	
	
