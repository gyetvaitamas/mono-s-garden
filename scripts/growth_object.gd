extends StaticBody2D

var health: int
var age: int

@export var data: GrowthData
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = data.age
	sprite_2d.texture = data.textures[data.age-1]
	sprite_2d.offset.y = data.texture_offsets[data.age-1]
