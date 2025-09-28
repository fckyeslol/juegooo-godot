extends CharacterBody2D

# --- Configurable desde el Inspector ---
@export var speed: float = 200.0
@export var bullet_scene: PackedScene             # arrastra aquí tu Bullet.tscn
@export var fire_rate: float = 1                  # tiempo entre balas en la ráfaga
@export var shot_anim_duration: float = 0.12      # tiempo en segundos que protegemos la anim "shoot"
@onready var barra_de_vida: ProgressBar = $BarraDeVida
# --- Salud ---
@export var max_health: int = 100
var health: int = max_health

# --- Hearts settings ---
# Si tu AnimatedSprite2D usa frame 0 = 5 corazones (completos) y frame 5 = 0,
# pon esto en true. Si frame 0 = 0 corazones y frame 5 = 5 corazones, déjalo en false.
@export var hearts_frames_inverted: bool = false

# --- Nodos ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
# buscaremos el nodo de corazones de forma segura en _ready()
var hearts: AnimatedSprite2D = null  # puede quedar null si no se encuentra

# --- Estado ---
var shooting: bool = false        # true mientras mantienes el click
var recently_shot: bool = false   # evita que get_input pise la anim de disparo
var dead: bool = false            # estado de muerte del jugador

func _ready():
	_find_hearts()
	_update_hearts()  # inicializa la UI
	barra_de_vida.min_value = 0
	barra_de_vida.max_value = max_health

func _process(_delta):
	if dead:
		return

	# empezar / parar la ráfaga
	if Input.is_action_just_pressed("shoot") and not shooting:
		shooting = true
		_start_shoot_loop()  # función async, se ejecuta en "paralelo"
	elif Input.is_action_just_released("shoot"):
		shooting = false

func _physics_process(_delta):
	if dead:
		return

	_get_input()
	move_and_slide()

func _get_input():
	# rotar hacia el ratón y mover
	look_at(get_global_mouse_position())
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	# Si recientemente disparamos, no sobrescribimos la animación "shoot"
	if recently_shot:
		return

	# Animaciones normales (walk / default / idle)
	if velocity != Vector2.ZERO:
		if not anim.is_playing() or anim.animation != "default":
			anim.play("default")
	else:
		if anim.is_playing():
			anim.stop()

# --- Ráfaga asíncrona ---
func _start_shoot_loop() -> void:
	while shooting and not dead:
		_single_shot()
		await get_tree().create_timer(fire_rate).timeout

func _single_shot() -> void:
	if bullet_scene == null:
		push_error("No has asignado 'bullet_scene' en el Inspector (arrastra Bullet.tscn).")
		return

	anim.play("shoot")
	recently_shot = true
	_clear_recent_shot_later(shot_anim_duration)

	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.rotation = rotation
	get_tree().current_scene.add_child(bullet)

func _clear_recent_shot_later(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
	recently_shot = false

# --- Recibir daño del enemigo ---
func handle_hit():
	if dead:
		return

	health -= 10
	health = clamp(health, 0, max_health)  # evita negativos
	print("💥 Jugador golpeado! Vida actual:", health)
	barra_de_vida.value -= 10
	_update_hearts()

	if health <= 0:
		die()

# --- Muerte del jugador ---
func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	print("☠️ El jugador ha muerto")

	if anim:
		anim.play("dead")

	# --- Espera 5 segundos y luego cambia a la escena de Game Over ---
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://GameOver.tscn")


# -------------------------
#  Funciones relacionadas con los corazones (UI)
# -------------------------
func _find_hearts() -> void:
	# Intentos de rutas comunes (ajusta si tu jerarquía difiere)
	hearts = get_node_or_null("Hearts")
	if hearts == null:
		hearts = get_node_or_null("HUD/Hearts")
	if hearts == null:
		hearts = get_node_or_null("CanvasLayer/Hearts")
	# Búsqueda por grupo (recomendado si tu HUD está en otra escena)
	if hearts == null:
		var nodes = get_tree().get_nodes_in_group("hearts_ui")
		if nodes.size() > 0:
			hearts = nodes[0]

	if hearts == null:
		push_warning("Hearts node not found. Añade un AnimatedSprite2D llamado 'Hearts' o agrégalo al grupo 'hearts_ui'.")
	else:
		# seguridad: confirmar tipo
		if not hearts is AnimatedSprite2D:
			push_error("Nodo 'Hearts' encontrado, pero no es AnimatedSprite2D.")
			hearts = null

func _update_hearts() -> void:
	# Protección: si no encontramos el nodo, simplemente no fallamos.
	if hearts == null:
		return

	# Calcula cuántos corazones (0..5)
	var hearts_count = int(round((health / float(max_health)) * 5.0))
	hearts_count = clamp(hearts_count, 0, 5)

	# Ajusta el frame según cómo hayas ordenado tus frames
	if hearts_frames_inverted:
		hearts.frame = 5 - hearts_count
	else:
		hearts.frame = hearts_count
		



	# (Opcional: debug)
	# print("Hearts updated -> health:", health, " hearts_count:", hearts_count, " frame:", hearts.frame)
