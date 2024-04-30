extends Polygon2D

func _ready():
    var size = 64
    var points = []
    for i in range(6):
        var angle = deg_to_rad(60 * i)
        points.append(Vector2(cos(angle), sin(angle)) * size)
    self.polygon = points
