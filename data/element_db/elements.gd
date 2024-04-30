extends Resource

enum StateOfMatter {
	GAS = 0,
	LIQUID = 1,
	SOLID = 2,
	MAX,
}

enum Category {
	FUNDAMENTAL = 0,
	ORGANIC = 1,
	MAX,
}

@export var element_name := ""
@export var state_of_matter : StateOfMatter
@export var category : Category
@export var name := ""
@export var symbol := ""
@export var min_temperature := 0.0
@export var max_temperature := 0.0
@export var can_burn := false
@export var can_melt := false
@export var can_freeze := false
@export var can_crush := false
