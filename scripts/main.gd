extends Node2D

@onready var level: Node2D = $Level
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	level.player.switch_tool.connect(hud.update_tool_selection)
