extends Node2D

@export var delay := 2.5
@onready var text_1 = $sprite_1/text_1
@onready var text_2 = $sprite_2/text_2
@onready var sprite_1 = $sprite_1
@onready var sprite_2 = $sprite_2

var index := 0
var label : Label
var current_box : Sprite2D

func display_array(array : Array[String]):
	for line in array:
		display_line(line)
		await get_tree().create_timer(delay).timeout
		sprite_1.visible = false
		sprite_2.visible = false

func display_line(line : String):
	if line.begins_with("0"):
		current_box = sprite_1
		label = text_1
	elif line.begins_with("1"):
		current_box = sprite_2
		label = text_2
	else:
		return
	label.text = line.erase(0, 1)
	fade_in(current_box)

func fade_in(box):
	box.visible = true
	box.modulate = Color(1, 1, 1, 0)
	box.position = Vector2(randf_range(-50, 50), randf_range(0, 10))
	var tween = create_tween()
	tween.tween_property(box, "modulate", Color(1, 1, 1, 1), 0.3).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(box, "position", Vector2(0, -10), 0.3).set_trans(Tween.TRANS_EXPO)
