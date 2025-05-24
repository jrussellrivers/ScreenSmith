extends Button

var value: int = 0
var is_highlighted: bool = false
var phase: int = 1

func _ready():
	_update_visual()

func highlight(on: bool):
	is_highlighted = on
	_update_visual()

func set_interactable(on: bool):
	disabled = not on

func progress_phase():
	phase += 1
	if phase > 3:
		get_parent().remove_button(self)
	else:
		value = randi_range(1, 3)
		_update_visual()
		# Notify parent grid to update stored value
		get_parent().update_button_value(self, value)


func _update_visual():
	text = str(value) + " (P" + str(phase) + ")"
	if is_highlighted:
		modulate = Color(1, 1, 0.5)
	elif phase == 1:
		modulate = Color(0.8, 0.8, 1)
	elif phase == 2:
		modulate = Color(0, 0, 1)
	elif phase == 3:
		modulate = Color(1, 0.6, 0.6)
	else:
		modulate = Color(1, 1, 1)
