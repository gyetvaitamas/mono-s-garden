extends Node2D

const FILL_PERCENTAGE: float = 0.4
const GROWTH_OBJECT_SCENE = preload("res://scenes/objects/growth_object.tscn")

@export var growth_types: Array[GrowthData] = []

@onready var growth_object_container: Node2D = $GrowthObjectContainer
@onready var current_map: Node2D = $Map
@onready var player: Player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_growth_object()
	_position_objects()

func _position_objects() -> void:
	var player_spawn: Marker2D = current_map.get_node("PlayerSpawn")
	player.reset(player_spawn.position)

func _generate_growth_object() -> void:
	# Clear existing ores
	for child in growth_object_container.get_children():
		child.queue_free()
	
	# Get tilemap layers from current map
	var ground_tiles: TileMapLayer = current_map.get_node("GroundTiles")
	var ground_cells := ground_tiles.get_used_cells()
	var soil_tiles: TileMapLayer = current_map.get_node("SoilTiles")
	var available_cells := []
	
	for cell in ground_cells:
		# Get the tile data for this specific coordinate
		var tile_data = ground_tiles.get_cell_tile_data(cell)
		
		# Check if there are any props in the way
		# get_cell_source_id returns -1 if the cell is empty
		if soil_tiles.get_cell_source_id(cell) != -1:
			continue
		
		# Check if this tile has the "can_spawn_ore" property
		if tile_data and tile_data.get_custom_data("can_spawn_growth_object") == true:
			available_cells.append(cell)
		
	available_cells.shuffle()
	
	var num_ores: int = int(available_cells.size() * FILL_PERCENTAGE)
	
	var valid_growth: Array[GrowthData] = []
	for growth in growth_types:
		valid_growth.append(growth)
	
	for i in range(num_ores):
		var cell = available_cells[i]
		var growth_object = GROWTH_OBJECT_SCENE.instantiate()
		growth_object.age = randi_range(1,4)
		
		growth_object.data = get_random_growth(valid_growth)
		
		# Get local position from tilemap
		var local_position = ground_tiles.map_to_local(cell)
		growth_object.global_position = local_position
		
		growth_object_container.add_child(growth_object)

func get_random_growth(options: Array[GrowthData]) -> GrowthData:
	var total_weigth: float = 0.0
	for growth in options:
		total_weigth += growth.rarity
	
	var roll: float = randf_range(0.0, total_weigth - 1.0)
	var current_sum: float = 0.0
	
	for growth in options:
		current_sum += growth.rarity
		if roll < current_sum:
			return growth
	
	return options[0] # Fallback to stone if nothing else is picked randomly
