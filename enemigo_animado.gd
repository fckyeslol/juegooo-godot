extends CharacterBody2D

@export var speed := 150          # Velocidad del enemigo
@export var attack_range := 50    # Distancia para atacar
@export var attack_cooldown := 1  # Tiempo entre ataques
@export var player_path: NodePath # Referencia al jugador

var player: Node2D
var can_attack := true

func _ready():
	player = get_node(player_path)

func _physics_process(delta):
	if not player:
		return
	
	var distance = global_position.distance_to(player.global_position)

	if distance > attack_range:
		# Perseguir al jugador
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		# Atacar si está cerca
		velocity = Vector2.ZERO
		if can_attack:
			attack()

func attack():
	can_attack = false
	# Aquí podrías activar animación de ataque o efectos
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
