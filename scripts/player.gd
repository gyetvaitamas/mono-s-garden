extends CharacterBody2D
class_name Player

const SPEED = 100.0

var is_mining: bool = false
var hitbox_offset: Vector2
var last_direction: Vector2 = Vector2.RIGHT
var detected_objects: Array = []
var tool_strength: int = 1
var can_move: bool = true

# var inventory: Inventory

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var cooldown_timer: Timer = $CooldownTimer

#@onready var pickaxe_hit_sound: AudioStreamPlayer2D = $PickaxeHitSound

signal switch_tool

func _ready() -> void:
	hitbox_offset = hitbox.position # Initialize the hitbox offset
	# inventory = Inventory.new(4) # Create inventory with 4 slots

func reset(pos: Vector2) -> void:
	position = pos
	last_direction = Vector2.DOWN
	velocity = Vector2.ZERO
	process_animation()
	update_hitbox_position()

func _physics_process(_delta: float) -> void:
	if !can_move:
		return
	
	# Handle mining input
	if Input.is_action_pressed("use_tool") and cooldown_timer.is_stopped():
		use_tool()
	
	# Skip movement if mining
	if is_mining:
		velocity = Vector2.ZERO
		return
	
	process_tool_switch()
	process_movement()
	process_animation()
	move_and_slide()

func process_tool_switch() -> void:
	if Input.is_action_just_pressed("switch_tool_1"):
		switch_tool.emit(1)
	elif Input.is_action_just_pressed("switch_tool_2"):
		switch_tool.emit(2)
	elif Input.is_action_just_pressed("switch_tool_3"):
		switch_tool.emit(3)

# Movement and animation
func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_position()
	else:
		velocity = Vector2.ZERO

func process_animation() -> void:
	# Disable hitbox until player swings pickaxe
	hitbox.monitoring = false
	
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, direction: Vector2) -> void:
	if direction.x != 0:
		animated_sprite_2d.flip_h = direction.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif direction.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif direction.y > 0:
		animated_sprite_2d.play(prefix + "_down")

# Hitbox offset
func update_hitbox_position() -> void:
	var x: float = hitbox_offset.x
	var y: float = hitbox_offset.y
	
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
			hitbox_collision_shape_2d.rotation_degrees = 0.0
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
			hitbox_collision_shape_2d.rotation_degrees = 0.0
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
			hitbox_collision_shape_2d.rotation_degrees = 90.0
		Vector2.DOWN:
			hitbox.position = Vector2(y, x)
			hitbox_collision_shape_2d.rotation_degrees = 90.0

# Mining
func use_tool() -> void:
	detected_objects.clear()
	is_mining = true
	hitbox.monitoring = true
	cooldown_timer.start() # Start the cooldown timer
	play_animation("swing_axe", last_direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_mining:
		is_mining = false
		if detected_objects.size() > 0:
			var object_to_hit = get_most_overlapping_object()
			object_to_hit.take_damage(tool_strength)
			#pickaxe_hit_sound.play()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is GrowthObject:
		detected_objects.append(body)

func get_most_overlapping_object() -> GrowthObject:
	var closest_object = detected_objects[0]
	var best_distance = hitbox.global_position.distance_to(closest_object.global_position)
	
	for object in detected_objects:
		var distance = hitbox.global_position.distance_to(object.global_position)
		if distance < best_distance:
			best_distance = distance
			closest_object = object
	
	return closest_object

func add_resource(data: ResourceData) -> bool:
	return true# inventory.add_item(data)
