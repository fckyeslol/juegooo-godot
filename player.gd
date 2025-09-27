extends CharacterBody2D

# 🔹 Velocidad del jugador
@export var speed: float = 200.0

# 🔹 Escena de la bala (así puedes arrastrar tu "Bullet.tscn" en el inspector)
@export var bullet_scene: PackedScene

# 🔹 Tiempo entre disparos (cooldown)
@export var fire_rate: float = 0.2
var time_since_last_shot: float = 0.0

func _process(delta: float) -> void:
	# --- Movimiento ---
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	velocity = direction.normalized() * speed
	move_and_slide()

	# --- Rotación hacia el mouse ---
	look_at(get_global_mouse_position())

	# --- Disparo ---
	time_since_last_shot += delta
	if Input.is_action_pressed("shoot") and time_since_last_shot >= fire_rate:
		shoot()
		time_since_last_shot = 0.0


func shoot() -> void:
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = global_position
		bullet.rotation = rotation
