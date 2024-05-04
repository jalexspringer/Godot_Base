extends Resource
class_name Flora

enum Category {
    TREES,
    SHRUBS,
    HERBACEOUS_PLANTS,
    AQUATIC_PLANTS,
    NON_VASCULAR_PLANTS,
    FUNGI
}

enum EcologicalFunction {
    PRIMARY_PRODUCERS,
    CARBON_SEQUESTRATION,
    SOIL_STABILIZATION,
    WATER_FILTRATION,
    HABITAT_PROVISION,
    DECOMPOSITION
}

enum GrowthForm {
    WOODY,
    HERBACEOUS,
    CLIMBING,
    CREEPING,
    FLOATING,
    FRUITING_BODY
}

@export var category: Category = Category.TREES
@export var ecological_function: EcologicalFunction = EcologicalFunction.PRIMARY_PRODUCERS
@export var growth_form: GrowthForm = GrowthForm.WOODY
@export var name: String = ""
@export var consumed_elements: Dictionary = {}
@export var consumed_quantities: Dictionary = {}
@export var generated_elements: Dictionary = {}
@export var generated_quantities: Dictionary = {}

func _init(p_name: String = "", p_category: Category = Category.TREES, p_ecological_function: EcologicalFunction = EcologicalFunction.PRIMARY_PRODUCERS,
            p_growth_form: GrowthForm = GrowthForm.WOODY, p_consumed_elements: Dictionary = {}, p_consumed_quantities: Dictionary = {},
            p_generated_elements: Dictionary = {}, p_generated_quantities: Dictionary = {}) -> void:
    name = p_name
    category = p_category
    ecological_function = p_ecological_function
    growth_form = p_growth_form
    consumed_elements = p_consumed_elements
    consumed_quantities = p_consumed_quantities
    generated_elements = p_generated_elements
    generated_quantities = p_generated_quantities