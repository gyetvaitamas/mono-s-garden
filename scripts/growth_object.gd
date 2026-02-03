extends StaticBody2D
class_name GrowthObject

const GROWTH_RESOURCE_SCENE := preload("res://scenes/objects/growth_resource.tscn")
const FLASH_COLOR := Color(2.454, 2.454, 2.454, 1.0)

@export var health: int
@export var age: int

@export var data: GrowthData
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var breaking_sound: AudioStreamPlayer2D = $BreakingSound
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

signal broken

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = age
	sprite_2d.texture = data.textures[age-1]
	sprite_2d.offset.y = data.texture_offsets[age-1]

func take_damage(amount: int) -> void:
	health -= amount
	_flash()
	if health <= 0:
		_drop_resource()
		_destroy() 

func _flash() -> void:
	sprite_2d.modulate = FLASH_COLOR
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)

func _destroy() -> void:
	# Hide rock
	visible = false
	collision_shape_2d.set_deferred("disabled", true)
	
	# Play sound
	breaking_sound.play()
	await breaking_sound.finished
	
	# Remove object
	queue_free()

func _drop_resource() -> void:
	broken.emit(position)
	var growth_resource = GROWTH_RESOURCE_SCENE.instantiate()
	growth_resource.position = position
	growth_resource.resource_data = data.resource_data
	growth_resource.age = age

	var level_root: Node = get_parent().get_parent()
	var growth_resource_container: Node = level_root.get_node("GrowthResourceContainer")
	growth_resource_container.add_child(growth_resource)
	
	# Random horizontal offset
	var random_x = randf_range(-15.0, 15.0)
	var target_x = growth_resource.position.x + random_x
	
	var tween = growth_resource.create_tween()
	tween.set_parallel(true) # Run tweens simultaneously
	
	# Vertical bounce
	tween.tween_property(growth_resource, "position:y", growth_resource.position.y - 20, 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(growth_resource, "position:y", growth_resource.position.y, 0.3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(0.3)
	
	# Horizontal bounce
	tween.tween_property(growth_resource, "position:x", target_x, 0.6)\
		.set_ease(Tween.EASE_OUT)
