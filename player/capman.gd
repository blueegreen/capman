extends Area2D


@onready var right = $right
@onready var down = $down
@onready var up = $up
@onready var left = $left

const SPEED = 300.0


var dir_h = 1
var dir_v = - 1

func _process(delta):
	await get_tree().create_timer(1).timeout
	if up.is_colliding() and down.is_colliding():
		if up.get_collider().is_in_group("food") and not down.get_collider().is_in_group("food"):
			position.y += SPEED * dir_v * delta
			#position.x += 0 * SPEED  * dir_h * delta
		elif not up.get_collider().is_in_group("food") and down.get_collider().is_in_group("food"):
			position.y += -1 * SPEED * dir_v *delta
			#position.x += 0 * SPEED * dir_h * delta
		elif up.get_collider().is_in_group("food") and down.get_collider().is_in_group("food"):
			position.y += dir_v * SPEED * delta
