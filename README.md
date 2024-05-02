# Godot_Base
A starter template for a 2D game in Godot

# Resource Descriptions
## Planets
The `Planet` class in Godot represents and generates planets for world creation. It has properties that define the characteristics and behavior of each planet, which are used to calculate various aspects of the planet's environment.

The `Planet` class has the following properties:

1. `name` (String): The name of the planet.
2. `solar_constant` (float, range: 1000-2000): The solar constant in W/m^2, representing the amount of solar energy received by the planet.
3. `radius` (float, range: 4000-8000): The planet's radius in kilometers.
4. `distance_from_sun` (float, range: 0.5-2.0): The distance from the sun in AU (Astronomical Units).
5. `axial_tilt` (float, range: 0-45): The axial tilt of the planet in degrees, affecting seasonal variations.
6. `albedo` (float, range: 0.0-1.0): The planet's reflectivity, determining how much solar energy is reflected back into space.
7. `gravity` (float, range: 0.5-1.5): The gravity relative to Earth's gravity.
8. `atmospheric_pressure` (float, range: 0.5-1.5): The atmospheric pressure relative to Earth's.
9. `magnetic_field_strength` (float, range: 0.5-1.5): The magnetic field strength relative to Earth's.
10. `orbital_period` (float, range: 200-500): The orbital period in Earth days.
11. `day_length` (float, range: 10-40): The day length in Earth hours.
12. `atmosphere` (Dictionary): A dictionary representing the composition of the planet's atmosphere, with keys for gases and their respective percentages.

The `Planet` class also has several calculated properties:

1. `average_temperature` (float): The average temperature of the planet in Celsius, calculated based on the solar constant, radius, distance from the sun, and albedo.
2. `tropical_zone_percentage` (float): The percentage of the planet's surface covered by the tropical climate zone.
3. `temperate_zone_percentage` (float): The percentage of the planet's surface covered by the temperate climate zone.
4. `polar_zone_percentage` (float): The percentage of the planet's surface covered by the polar climate zone.
5. `spin_speed` (float): The spin speed of the planet in kilometers per second, calculated based on the day length and radius.
6. `average_wind_speed` (float): The estimated average wind speed on the planet, calculated based on the spin speed, axial tilt, and atmospheric pressure.

The `Planet` class has several functions that calculate various properties:

1. `get_cross_sectional_area()`: Calculates the cross-sectional area of the planet in square meters.
2. `get_total_solar_energy()`: Calculates the total solar energy received by the planet in watts.
3. `calculate_average_temperature()`: Calculates the average temperature of the planet using the Stefan-Boltzmann law.
4. `calculate_climate_zones()`: Calculates the percentage of the planet's surface covered by each climate zone (tropical, temperate, and polar).
5. `calculate_spin_speed()`: Calculates the spin speed of the planet based on its day length and radius.
6. `estimate_average_wind_speed()`: Estimates the average wind speed on the planet based on its spin speed, axial tilt, and atmospheric pressure.

These properties and functions are used to generate realistic and diverse planets for world creation, taking into account various physical and environmental factors that shape the planet's characteristics.

## Climate Zones

Here's a brief description of each climate zone, along with a reference area from Earth as an example:

1. TROPICAL_RAINFOREST: Hot and wet year-round, with dense vegetation and high biodiversity. (e.g., Amazon Rainforest, Brazil)
2. TROPICAL_MONSOON: Seasonal rainfall patterns, with a pronounced wet season and a dry season. (e.g., Southeast Asia, India)
3. TROPICAL_SAVANNA: Grasslands with scattered trees, hot year-round with distinct wet and dry seasons. (e.g., Serengeti, Tanzania)
4. SUBTROPICAL_HUMID: Warm and humid, with rainfall throughout the year and mild winters. (e.g., Southeastern United States)
5. SUBTROPICAL_DESERT: Hot and arid regions with low precipitation and mild winters. (e.g., Sahara Desert, North Africa)
6. TEMPERATE_OCEANIC: Mild temperatures, high humidity, and frequent rainfall throughout the year. (e.g., Western Europe)
7. TEMPERATE_CONTINENTAL: Large seasonal temperature variations, with cold winters and warm summers. (e.g., Eastern Europe, Russia)
8. TEMPERATE_STEPPE: Semi-arid grasslands, with hot summers and cold winters. (e.g., Great Plains, United States)
9. TEMPERATE_DESERT: Arid regions with low precipitation and large temperature variations. (e.g., Gobi Desert, Mongolia)
10. BOREAL_FOREST: Coniferous forests, with long, cold winters and short, mild summers. (e.g., Siberia, Russia)
11. TUNDRA: Treeless regions with permafrost, extremely cold winters, and short, cool summers. (e.g., Arctic regions of North America and Eurasia)
12. POLAR_ICE_CAP: Perpetually covered in ice and snow, with extremely cold temperatures year-round. (e.g., Antarctica)
13. ALPINE: High-altitude regions with cold temperatures, often above the tree line. (e.g., Swiss Alps, Europe)
14. OCEAN_TROPICAL: Warm ocean waters near the equator, supporting coral reefs and diverse marine life. (e.g., Great Barrier Reef, Australia)
15. OCEAN_TEMPERATE: Moderate ocean temperatures, supporting a variety of marine ecosystems. (e.g., North Atlantic Ocean)
16. OCEAN_POLAR: Cold ocean waters near the poles, often covered by sea ice. (e.g., Southern Ocean, Antarctica)
17. LAKE_TROPICAL: Warm, freshwater lakes in tropical regions, supporting diverse aquatic life. (e.g., Lake Victoria, Africa)
18. LAKE_TEMPERATE: Freshwater lakes in temperate regions, with seasonal temperature variations. (e.g., Great Lakes, North America)
19. LAKE_ALPINE: Cold, freshwater lakes in mountainous regions, often covered by ice for much of the year. (e.g., Lake Vostok, Antarctica)


## Elements
The `Element` class in Godot represents various elements in a simulated environment. These elements can be fundamental building blocks, minerals, organic compounds, or constructed elements. The class has properties that define the characteristics and behavior of each element.

The `Element` class has the following properties:

1. `StateOfMatter` (enum):
   - `SOLID`: The element is in a solid state.
   - `LIQUID`: The element is in a liquid state.
   - `GAS`: The element is in a gaseous state.
   - `PLASMA`: The element is in a plasma state.

2. `Category` (enum):
   - `FUNDAMENTAL`: Fundamental elements are the building blocks of the universe.
   - `MINERAL`: Minerals are composed of one or more fundamental elements.
   - `ORGANIC`: Organic compounds are composed of one or more minerals.
   - `CONSTRUCTED`: Constructed elements are created by the human imagination out of other elements.
   - `OTHER`: Other elements are not categorized.

3. Other properties:
   - `state_of_matter` (StateOfMatter): The current state of matter of the element.
   - `category` (Category): The category to which the element belongs.
   - `name` (String): The name of the element.
   - `symbol` (String): The symbol or abbreviation for the element.
   - `min_temperature` (float): The minimum temperature at which the element can exist.
   - `max_temperature` (float): The maximum temperature at which the element can exist.
   - `can_burn` (bool): Indicates if the element is flammable.
   - `can_melt` (bool): Indicates if the element can melt.
   - `can_freeze` (bool): Indicates if the element can freeze.
   - `can_crush` (bool): Indicates if the element can be crushed or compressed.
   - `recipes` (Array[Recipe]): An array of Recipe resources associated with the element.

## Flora and Fauna
The `Flora` and `Fauna` classes in Godot represent different types of plants and animals in a simulated ecosystem. These classes have various properties that define their ecological roles, interactions, and impact on the environment.

#### Flora Class
The `Flora` class has the following properties:

1. `Category` (enum):
   - `TREES`: Woody perennial plants with a single stem or trunk.
   - `SHRUBS`: Woody plants with multiple stems growing from the base.
   - `HERBACEOUS_PLANTS`: Non-woody plants with soft stems.
   - `AQUATIC_PLANTS`: Plants adapted to grow in water.
   - `TREES`: Woody perennial plants with a single stem or trunk
   - `SHRUBS`: Woody plants with multiple stems growing from the base
   - `HERBACEOUS_PLANTS`: Non-woody plants with soft stems
   - `AQUATIC_PLANTS`: Plants adapted to grow in water
   - `NON_VASCULAR_PLANTS`: Plants without a vascular system (e.g., mosses, liverworts)
   - `FUNGI`: Eukaryotic organisms distinct from plants and animals

2. `EcologicalFunction` (enum):
   - `PRIMARY_PRODUCERS`: Produce organic compounds from inorganic sources (e.g., photosynthesis)
   - `CARBON_SEQUESTRATION`: Capture and store atmospheric carbon dioxide
   - `SOIL_STABILIZATION`: Prevent soil erosion and improve soil structure
   - `WATER_FILTRATION`: Filter and purify water by absorbing pollutants
   - `HABITAT_PROVISION`: Provide shelter and resources for other organisms
   - `DECOMPOSITION`: Break down dead organic matter and recycle nutrients

3. `GrowthForm` (enum):
   - `WOODY`: Plants with hard, lignified stems (e.g., trees, shrubs)
   - `HERBACEOUS`: Plants with soft, non-woody stems
   - `CLIMBING`: Plants that grow by attaching to and climbing other structures
   - `CREEPING`: Plants that grow along the ground, often rooting at nodes
   - `FLOATING`: Aquatic plants that float on the water surface
   - `FRUITING_BODY`: Reproductive structures of fungi

4. Other properties:
   - `name` (String): Name of the flora species
   - `consumed_elements` (Dictionary): Elements consumed by the flora for growth and maintenance
   - `consumed_quantities` (Dictionary): Quantities of elements consumed by the flora
   - `generated_elements` (Dictionary): Elements generated or released by the flora
   - `generated_quantities` (Dictionary): Quantities of elements generated or released by the flora

#### Fauna Class
The `Fauna` class has the following properties:

1. `Category` (enum):
   - `MAMMALS`: Warm-blooded vertebrates that nurse their young with milk
   - `BIRDS`: Warm-blooded, egg-laying vertebrates with feathers and wings
   - `REPTILES`: Cold-blooded, air-breathing vertebrates with scaly skin
   - `AMPHIBIANS`: Cold-blooded vertebrates that undergo metamorphosis (e.g., frogs, salamanders)
   - `FISH`: Aquatic, cold-blooded vertebrates with gills and fins
   - `INVERTEBRATES`: Animals without a backbone (e.g., insects, spiders, crustaceans)

2. `TrophicLevel` (enum):
   - `PRODUCERS`: Organisms that produce their own food (e.g., plants, algae)
   - `PRIMARY_CONSUMERS`: Herbivores that feed on producers
   - `SECONDARY_CONSUMERS`: Carnivores that feed on herbivores
   - `TERTIARY_CONSUMERS`: Carnivores that feed on other carnivores
   - `DECOMPOSERS`: Organisms that break down dead organic matter (e.g., bacteria, fungi)

3. `EcologicalFunction` (enum):
   - `KEYSTONE_SPECIES`: Species with a disproportionately large impact on the ecosystem
   - `ECOSYSTEM_ENGINEERS`: Species that modify or create habitats (e.g., beavers, elephants)
   - `POLLINATORS_AND_SEED_DISPERSERS`: Species that facilitate plant reproduction and dispersal
   - `NUTRIENT_CYCLERS`: Species that break down and recycle nutrients (e.g., decomposers, detritivores)
   - `HABITAT_PROVIDERS`: Species that provide shelter or resources for other organisms

4. Other properties:
   - `name` (String): Name of the fauna species
   - `consumed_elements` (Dictionary): Elements consumed by the fauna for growth and maintenance
   - `consumed_quantities` (Dictionary): Quantities of elements consumed by the fauna
   - `generated_elements` (Dictionary): Elements generated or released by the fauna
   - `generated_quantities` (Dictionary): Quantities of elements generated or released by the fauna

These classes allow for modeling the presence, volume, and impact of flora and fauna on a given climate zone. By defining the ecological roles, interactions, and resource consumption/generation of each species, the system can simulate the effects of adding or removing specific flora or fauna from an ecosystem.

When creating instances of the `Flora` and `Fauna` classes, the appropriate enums can be selected to define the category, ecological function, growth form (for flora), and trophic level (for fauna). The dictionaries for consumed and generated elements and quantities can be populated to represent the species' resource requirements and outputs.
