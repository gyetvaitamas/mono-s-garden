extends CanvasLayer

@export var tool_selection_textures: Array[TextureRect]

@onready var axe_texture: TextureRect = $ToolsTextureContainer/BackgroundTexture/AxeTexture
@onready var hoe_texture: TextureRect = $ToolsTextureContainer/BackgroundTexture/HoeTexture
@onready var watering_texture: TextureRect = $ToolsTextureContainer/BackgroundTexture/WateringTexture

func update_tool_selection(active_tool: int) -> void:
	for item in tool_selection_textures:
		item.visible = false
	
	tool_selection_textures[active_tool-1].visible = true
