extends Area2D

@export var speed: float = 800
@export var lifetime: float = 1.5
var direction: Vector2

func _ready():
	# Dirección inicial hacia donde mira la bala
	direction = Vector2.RIGHT.rotated(rotation)
	# Autodestrucción tras cierto tiempo
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta
	
func _on_KillTimer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	print("Colisión con:", body.name)
	if body.has_method("handle_hit"):
		body.handle_hit()
		queue_free()
	elif body.get_parent() and body.get_parent().has_method("handle_hit"):
		body.get_parent().handle_hit()
		queue_free()
	else:
		queue_free()
