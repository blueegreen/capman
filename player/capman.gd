extends Area2D

@onready var right = $right
@onready var down = $down
@onready var up = $up
@onready var left = $left

const SPEED = 100.0

var dir_h = 1
var dir_v = -1

var velocity_x = dir_h * SPEED
var velocity_y = dir_v * SPEED

func _process(delta):
	await get_tree().create_timer(1).timeout
	
	if up.is_colliding() and not down.is_colliding():
		if up.get_collider().is_in_group("food"):
			dir_v = -1
			position.y += velocity_y*delta
		elif up.get_collider().is_in_group("walls"):
			velocity_y = 0
	if down.is_colliding() and not up.is_colliding():
		if down.get_collider().is_in_group("food"):
			dir_v = 1
			position.y += velocity_y*delta
		elif down.get_collider().is_in_group("walls"):
			velocity_y = 0
	if left.is_colliding() and not right.is_colliding():
		if left.get_collider().is_in_group("food"):
			dir_h = -1
			position.x += velocity_x*delta
		elif left.get_collider().is_in_group("walls"):
			velocity_x = 0
	if right.is_colliding() and not left.is_colliding():
		if right.get_collider().is_in_group("food"):
			dir_h = 1
			position.x += 1*velocity_x*delta
		elif right.get_collider().is_in_group("walls"):
			velocity_x = 0
	if not up.is_colliding() and not down.is_colliding():
		position.y += velocity_y * delta
	if not right.is_colliding() and not left.is_colliding():
		position.x += velocity_x*delta
