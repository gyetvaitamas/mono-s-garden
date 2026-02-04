extends Area2D

var resource_data: ResourceData
var age: int
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var pickup_timer: Timer = $PickupTimer

func _ready() -> void:
	set_texture(age)

# Called when the node enters the scene tree for the first time.
func set_texture(age: int) -> void:
	sprite_2d.texture = resource_data.textures[age-1]

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.add_resource(resource_data) and pickup_timer.is_stopped():
		queue_free()
