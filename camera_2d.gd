extends Camera2D

func _ready():
	enabled = true
	make_current()
	zoom = Vector2(1.5, 1.5)
