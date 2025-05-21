extends TouchScreenButton
class_name General_Touch
@onready var l_container: VBoxContainer = $CanvasLayer/LContainer
@onready var l_touch: TouchScreenButton = $CanvasLayer/LContainer/LTouch
@onready var touchdelay: Timer = $Touchdelay

const act: Array[String] = ["left_click","right_click"]
var cin = 0
#func _ready():
	#l_touch.transform
	#l_touch.shape.size.x = DisplayServer.screen_get_size().x / 2
	#l_touch.shape.size.y = DisplayServer.screen_get_size().y
	#print(l_touch.shape.size)
	
func _process(delta):
	if l_touch.is_pressed():
		l_hold()

func _on_switch_rotation_pressed() -> void:
	cin += 1
	cin = cin%2
	self.action = act[cin]
	print(self.get_action())
	
#func _on_l_touch_pressed() -> void:
	#print("hi")
#
#
#func _on_r_touch_pressed() -> void:
	#print("hi2")
	
func l_hold():
	if !l_touch.is_pressed():
		return
	await get_tree().create_timer(2).timeout
	if !l_touch.is_pressed():
		return
	print("hi")
