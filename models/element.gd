extends Resource
class_name Element

enum StateOfMatter {
    SOLID,
    LIQUID,
    GAS,
    PLASMA
}

enum Category {
    FUNDAMENTAL, # Fundamental elements are the building blocks of the universe
    MINERAL, # Minerals are composed of one or more fundamental elements
    ORGANIC, # Organic compounds are composed of one or more minerals
    CONSTRUCTED, # Constructed elements are created by the human imagination out of other elements
    OTHER # Other elements are not categorized
}

@export var state_of_matter: StateOfMatter = StateOfMatter.SOLID
@export var category: Category = Category.OTHER
@export var name: String = ""
@export var symbol: String = ""
@export var min_temperature: float = 0.0
@export var max_temperature: float = 0.0
@export var can_burn: bool = false
@export var can_melt: bool = false
@export var can_freeze: bool = false
@export var can_crush: bool = false
@export var recipes: Array[Recipe] = []  # Array of Recipe resources

func _init(p_name: String = "", p_symbol: String = "", p_category: Category = Category.OTHER, p_state_of_matter: StateOfMatter = StateOfMatter.SOLID,
            p_min_temperature: float = 0.0, p_max_temperature: float = 0.0, p_can_burn: bool = false, p_can_melt: bool = false,
            p_can_freeze: bool = false, p_can_crush: bool = false, p_recipes: Array[Recipe] = []) -> void:
    name = p_name
    symbol = p_symbol
    category = p_category
    state_of_matter = p_state_of_matter
    min_temperature = p_min_temperature
    max_temperature = p_max_temperature
    can_burn = p_can_burn
    can_melt = p_can_melt
    can_freeze = p_can_freeze
    can_crush = p_can_crush
    recipes = p_recipes