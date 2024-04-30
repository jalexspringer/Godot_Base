extends Resource
class_name Recipe

@export var ingredients: Dictionary  # Dictionary of Element, Flora, or Fauna resources and their quantities
@export var outputs: Dictionary  # Dictionary of Element, Flora, or Fauna resources and their quantities
@export var facility_type: String = "NONE"  # The required crafting facility for the recipe

func _init(p_ingredients: Dictionary = {}, p_outputs: Dictionary = {}, p_facility_type: String = "NONE") -> void:
    ingredients = p_ingredients
    outputs = p_outputs
    facility_type = p_facility_type
