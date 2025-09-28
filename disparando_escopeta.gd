extends CharacterBody2D

var bullet = preload("res://Bullet.tscn")

func _physics_process(delta):
	look_at(get_global_mouse_position())
	if Input.is_action_pressed("accept"):
		print("shoot")
		shoot()
		 
func shoot():
	var newBullet = bullet.instantiate()
	newBullet.direction=rotation
	newBullet.global_position = $SpawnPoint.global_position
	get_parent().add_child(newBullet)
