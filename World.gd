extends Node2D

export var height := 75
export var width := 128

onready var tilemap = $TileMap
onready var sim_timer = $SimTimer
onready var living_cells_label = $UI/Stats/LivingCells
onready var generations_label = $UI/Stats/Generation
onready var controls = $UI/Controls
onready var start = $UI/Start
onready var start_button = $UI/Start/Start
onready var controls_panel = $UI/Controls

var grid
var living_cells := 0
var current_gen := 0

func _ready():
	grid = generate_grid()
	draw_grid(grid)
	living_cells = count_cells()
	update_stats(living_cells, current_gen)

# warning-ignore:unused_argument
func _process(delta):
	living_cells = count_cells()

func generate_grid() -> Array:
	var grid = []
	
	for x in range(width):
		grid.append([])
		grid[x] = []
		for y in range(height):
			grid[x].append([])
			if rand_range(0,1) > .7:
				grid[x][y] = 1
			else:
				grid[x][y] = 0
	return grid

func draw_grid(g: Array) -> void:
	clear_grid()
	for x in range(width):
		for y in range(height):
			if g[x][y] == 1:
				tilemap.set_cell(x,y,0)

func clear_grid() -> void:
	for x in range(width):
		for y in range(height):
			tilemap.set_cell(x,y,-1)

func count_cells() -> int:
	var sum := 0
	for x in range(width):
		for y in range(height):
			if tilemap.get_cell(x,y) == 0:
				sum += 1
	return sum

func update_stats(c: int,g: int) -> void:
	living_cells_label.text = 'Living Cells: ' + str(c)
	generations_label.text = 'Generations Passed: ' + str(g)

func get_next_generation(g: Array) -> void:
	var next_gen := g.duplicate(true)
	
	for x in range(width):
		next_gen.append([])
		next_gen[x] = []
		for y in range(height):
			next_gen[x].append([])
			var val = g[x][y]
			var neighbors = count_neighbors(g,x,y)
			if val == 0 and neighbors == 3:
				next_gen[x][y] = 1
			elif val == 1 and (neighbors < 2 or neighbors > 3):
				next_gen[x][y] = 0
			else:
				 next_gen[x][y] = val
	grid = next_gen

func count_neighbors(g, x, y) -> int:
	var sum := 0
	
	for i in range(-1,2):
		for j in range(-1,2):
			var r = (x + i + width) % width
			var c = (y + j + height) % height
			sum += g[r][c]
	sum -= g[x][y]
	return sum

func _on_Start_pressed():
	start.visible = false
	controls_panel.visible = true
	sim_timer.start()

func _on_SimTimer_timeout():
	get_next_generation(grid)
	draw_grid(grid)
	current_gen += 1
	update_stats(living_cells, current_gen)

func _on_Pause_toggled(button_pressed):
	if(button_pressed):
		sim_timer.stop()
	else:
		sim_timer.start()

func _on_Restart_pressed():
	get_tree().reload_current_scene()
