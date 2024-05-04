extends Resource
class_name Fauna

enum Category {
    MAMMALS,
    BIRDS,
    REPTILES,
    AMPHIBIANS,
    FISH,
    INVERTEBRATES
}

enum TrophicLevel {
    PRODUCERS,
    PRIMARY_CONSUMERS,
    SECONDARY_CONSUMERS,
    TERTIARY_CONSUMERS,
    DECOMPOSERS
}

enum EcologicalFunction {
    KEYSTONE_SPECIES,
    ECOSYSTEM_ENGINEERS,
    POLLINATORS_AND_SEED_DISPERSERS,
    NUTRIENT_CYCLERS,
    HABITAT_PROVIDERS
}

@export var category: Category = Category.MAMMALS
@export var trophic_level: TrophicLevel = TrophicLevel.PRIMARY_CONSUMERS
@export var ecological_function: EcologicalFunction = EcologicalFunction.KEYSTONE_SPECIES
@export var name: String = ""
@export var consumed_elements: Dictionary = {}
@export var consumed_quantities: Dictionary = {}
@export var generated_elements: Dictionary = {}
@export var generated_quantities: Dictionary = {}

func _init(p_name: String = "", p_category: Category = Category.MAMMALS, p_trophic_level: TrophicLevel = TrophicLevel.PRIMARY_CONSUMERS,
            p_ecological_function: EcologicalFunction = EcologicalFunction.KEYSTONE_SPECIES,
            p_consumed_elements: Dictionary = {}, p_consumed_quantities: Dictionary = {},
            p_generated_elements: Dictionary = {}, p_generated_quantities: Dictionary = {}) -> void:
    name = p_name
    category = p_category
    trophic_level = p_trophic_level
    ecological_function = p_ecological_function
    consumed_elements = p_consumed_elements
    consumed_quantities = p_consumed_quantities
    generated_elements = p_generated_elements
    generated_quantities = p_generated_quantities