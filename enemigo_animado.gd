extends CharacterBody2D

@export var speed: float = 150
@export var attack_cooldown: float = 1.0   # tiempo entre golpes
@export var damage: int = 20               # daño que inflige al jugador

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var attack_area: Area2D = $attackarea
@onready var barra_de_vida = $healthcomp/BarraDeVida
@onready var attack_timer: Timer = $AttackTimer   # 👈 NUEVO (añádelo en el árbol de nodos)
@export var max_health: int = 90
var health: int = max_health
var dead: bool = false
var player: Node2D = null
var in_attack_range: bool = false

func _ready() -> void:
	# Conectar señales del área de ataque
	attack_area.body_entered.connect(_on_attackarea_body_entered)
	attack_area.body_exited.connect(_on_attackarea_body_exited)

	# Buscar jugador en la escena
	player = get_tree().get_first_node_in_group("player")

	# 👇 Inicializar barra de vida
	if barra_de_vida:
		barra_de_vida.init_health(health)

	# 👇 Configurar el Timer de ataque
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta: float) -> void:
	if player:
		# Seguir al jugador con el NavigationAgent2D
		nav.target_position = player.global_position
		if nav.is_navigation_finished() == false:
			var next_path_pos = nav.get_next_path_position()
			velocity = (next_path_pos - global_position).normalized() * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

	# --- Animaciones ---
	if in_attack_range:
		if anim.animation != "attack":
			anim.play("attack")
	else:
		if velocity.length() > 0.1:
			if anim.animation != "walk":
				anim.play("walk")
		else:
			if anim.animation != "idle":
				anim.play("idle")

	move_and_slide()


# --- Señales del área de ataque ---
func _on_attackarea_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		in_attack_range = true
		attack_timer.start()  # 👈 empezar a atacar

func _on_attackarea_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		in_attack_range = false
		attack_timer.stop()   # 👈 dejar de atacar

# --- Timer de ataque ---
func _on_attack_timer_timeout() -> void:
	if in_attack_range and player and not dead:
		if player.has_method("handle_hit"):
			player.handle_hit()  # 👈 el jugador recibe daño


# --- Recibir daño ---
func handle_hit():
	health -= 1
	print("⚔️ Enemigo golpeado! Vida actual:", health)
	#health = clamp(health, 0, max_health)
	barra_de_vida.value -= 1

	# 👇 Actualizar la barra de vida
	#if barra_de_vida:
		#barra_de_vida.health = health
		
#	health = clamp(health, 0, health)  
	
	
	if health <= 0:
		die()

func die() -> void:
	dead = true
	print("💀 Enemigo derrotado!")
	velocity = Vector2.ZERO
	set_physics_process(false)
	if attack_area:
		attack_area.monitoring = false

	# --- Espera 2 segundos y luego cambia a la escena de YouWin ---
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://YouWin.tscn")


	if anim:
		anim.play("dead")
		# Espera a que termine la animación (signal awaitable)
		await anim.animation_finished
		# Si la animación que terminó es 'dead', eliminar el nodo
		if anim.animation == "dead":
			queue_free()
	else:
		queue_free()
