extends Node2D

const GRID_SIZE = 6
const CELL_SIZE = 60
const BUTTON_SCENE = preload("res://button.tscn")
const BLANK_SCENE = preload("res://blank_spot.tscn")
var button_grid := []
var has_started := false

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for x in range(GRID_SIZE):
		var row := []
		for y in range(GRID_SIZE):
			var button = BUTTON_SCENE.instantiate()
			button.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)

			var value = rng.randi_range(1, 3)
			button.set("value", value)  # assumes button has a 'value' property
			button.highlight(false)
			button.set_interactable(true)
			button.set("grid_x", x)
			button.set("grid_y", y)

			button.pressed.connect(_on_button_pressed.bind(x, y, value))
			add_child(button)

			row.append({
				"x": x,
				"y": y,
				"value": value,
				"button": button
			})
		button_grid.append(row)


func _on_button_pressed(x: int, y: int, value: int):
	if not has_started:
		has_started = true

	# Disable & unhighlight all buttons
	for row in button_grid:
		for cell in row:
			var btn = cell["button"]
			if btn != null:
				btn.highlight(false)
				btn.set_interactable(false)

	var origin_btn = button_grid[x][y]["button"]

	# Store original value BEFORE phase progression
	var original_value = origin_btn.value

	# Highlight & enable neighbors based on original value
	var directions = [
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN,
	]

	for dir in directions:
		var nx = x + int(dir.x) * original_value
		var ny = y + int(dir.y) * original_value

		nx = clamp(nx, 0, GRID_SIZE - 1)
		ny = clamp(ny, 0, GRID_SIZE - 1)

		if nx == x and ny == y:
			continue

		var neighbor_cell = button_grid[nx][ny]
		if neighbor_cell != null and neighbor_cell["button"] != null:
			neighbor_cell["button"].highlight(true)
			neighbor_cell["button"].set_interactable(true)

	# Now progress the button’s phase and update its value/color
	origin_btn.progress_phase()


func remove_button(button_node):
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if button_grid[x][y]["button"] == button_node:
				remove_child(button_node)
				button_node.queue_free()

				var blank = BLANK_SCENE.instantiate()
				blank.position = Vector2(x * 40, y * 40)
				add_child(blank)

				# IMPORTANT: update the grid to remove the button reference
				button_grid[x][y] = {"button": null, "x": x, "y": y}
				return

func update_button_value(button_node, new_value):
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if button_grid[x][y]["button"] == button_node:
				button_grid[x][y]["value"] = new_value
				return
