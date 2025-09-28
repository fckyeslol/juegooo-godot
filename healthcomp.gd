extends Node2D

@export var MAX_HEALTH: float = 30.0   # Vida inicial (equivalente al daño de 30 balas, ajusta si lo necesitas)
var health: float

 # Referencia al nodo con el script barra_de_vida.gd
@onready var barra_de_vida: ProgressBar = $BarraDeVida

func _ready() -> void:
	health = MAX_HEALTH
	# Inicializa la barra usando su propia función
	barra_de_vida.init_health(MAX_HEALTH)

func damage(attack: float) -> void:
	health -= attack
	# Actualiza la barra con animación y efectos
	barra_de_vida.set_health(health)

	if health <= 0:
		die()


func die() -> void:
	# Aquí luego puedes cambiar por animación de muerte antes de borrar
	get_parent().queue_free()
