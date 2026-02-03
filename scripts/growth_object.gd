extends StaticBody2D
class_name GrowthObject

var health: int
var age: int

@export var data: GrowthData
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = data.age
	sprite_2d.texture = data.textures[data.age-1]
	sprite_2d.offset.y = data.texture_offsets[data.age-1]

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_destroy()

func _destroy() -> void:
	queue_free()
